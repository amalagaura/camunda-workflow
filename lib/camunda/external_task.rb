require 'active_support/core_ext/string/inflections.rb'
require 'active_support/backtrace_cleaner'
# External Tasks are the task entity for camunda. We can query the topic and lock the task. After the task
# is locked, the external task of the process instance can be worked and completed. Below is an excerpt from the Camunda
# documentation regarding the ExternalTask process.
# @see https://docs.camunda.org/manual/7.7/user-guide/process-engine/external-tasks/
# "When the process engine encounters a service task that is configured to be externally handled, it creates an external task
# instance and adds it to a list of external tasks(step 1). The task instance receives a topic that identifies the nature of
# the work to be performed. At a time in the future, an external worker may fetch and lock tasks for a specific set of
# topics (step 2). To prevent one task being fetched by multiple workers at the same time, a task has a timestamp-based lock
# that is set when the task is acquired. Only when the lock expires, another worker can fetch the task again. When an external
# worker has completed the desired work, it can signal the process engine to continue process execution after the service
# task (step 3)."
class Camunda::ExternalTask < Camunda::Model
  # Camunda engine doesn't searching on snake_case variables.
  include Camunda::VariableSerialization
  # collection_path sets the path for Her in Camunda::Model
  collection_path 'external-task'
  custom_post :fetchAndLock, :unlock

  # @note long_polling_duration is defaulted to 30 seconds in Camunda::Workflow.configuration.
  # @return [Integer] default polling duration from Camunda::Workflow configuration
  def self.long_polling_duration
    Camunda::Workflow.configuration.long_polling_duration.in_milliseconds
  end

  # @note Max polling tasks is defaulted to 2 in Camunda::Workflow.configuration.
  # @return [Integer] sets the max polling tasks
  def self.max_polling_tasks
    Camunda::Workflow.configuration.max_polling_tasks
  end

  # Default lock duration time is set to 14 days in Camunda::Workflow.configuration.
  # @return [Integer] default lock duration time
  def self.lock_duration
    Camunda::Workflow.configuration.lock_duration.in_milliseconds
  end

  # Reports a failure to Camunda process definition and creates an incident for a process instance.
  # @param input_variables [Hash] process variables
  def failure(exception, input_variables={})
    variables_information = "Input variables are #{input_variables.inspect}\n\n" if input_variables.present?
    self.class.post_raw("#{collection_path}/#{id}/failure",
                        workerId: worker_id, errorMessage: exception.message,
                        errorDetails:
                          variables_information.to_s + exception.message +
                          backtrace_cleaner.clean(exception.backtrace).join("\n"))[:response]
  end

  # Reports the error to Camunda and creates an incident for the process instance.
  # @param bpmn_exception [Camunda::BpmnError]
  def bpmn_error(bpmn_exception)
    self.class.post_raw("#{collection_path}/#{id}/bpmnError",
                        workerId: worker_id, variables: serialize_variables(bpmn_exception.variables),
                        errorCode: bpmn_exception.error_code, errorMessage: bpmn_exception.message)[:response]
  end

  # Completes the process instance of a fetched task
  # @param variables [Hash] submitted when starting the process definition
  # @raise [Camunda::ExternalTask::SubmissionError] if Camunda does not accept the task submission
  def complete(variables={})
    self.class.post_raw("#{collection_path}/#{id}/complete",
                        workerId: worker_id, variables: serialize_variables(variables))[:response]
        .tap do |response|
      raise SubmissionError, response.body[:data][:message] unless response.success?
    end
  end

  # Returns the worker id for an external task
  # @note default is set to '0' in Camunda::Workflow.configuration
  # @return [String]
  def worker_id
    self.class.worker_id
  end

  # Helper method for instances since collection_path is a class method
  # @return [String]
  def collection_path
    self.class.collection_path
  end

  # deserializes JSON attributes from variables returned by Camunda API
  def variables
    super.transform_values do |details|
      if details['type'] == 'Json'
        JSON.parse(details['value'])
      else
        details['value']
      end
    end
  end

  # Queues the task to run at a specific time via ActiveJob
  # @example
  #   # Below will retrieve current running process instances with the definition key "CamundaWorkflow"
  #   # and queues the instances to be run at a specific time.
  #   task = Camunda::ExternalTask.fetch_and_lock("CamundaWorkflow")
  #   task.each(&:queue_task)
  # @return [Camunda::ExternalTask]
  def queue_task
    task_class.perform_later(id, variables)
  end

  # Runs the task using ActiveJob based on the classes created by bpmn_classes_generator. Before an external task
  # can be run, you must #fetch_and_lock the task.
  # @see fetch_and_lock
  # @example
  #   # Below will retrieve current running process instances with the definition key "CamundaWorkflow"
  #   # and run the instances.
  #   task = Camunda::ExternalTask.fetch_and_lock("CamundaWorkflow")
  #   task.each(&:run_now)
  # @return [Camunda::ExternalTask]
  def run_now
    task_class_name.safe_constantize.perform_now id, variables
  end

  # Locking means that the task is reserved for this worker for a certain duration beginning with the time of fetching and
  # prevents that another worker can fetch the same task while the lock is valid. Locking duration is set in the the
  # Camunda::Workflow configuration. Before an external task can be completed, it must be locked.
  # @example
  #   task = Camunda::ExternalTask.fetch_and_lock("CamundaWorkflow")
  # @param topics [Array<String>] definition keys
  # @param lock_duration [Integer]
  # @param long_polling_duration [Integer]
  # @return [Camunda::ExternalTask]
  def self.fetch_and_lock(topics, lock_duration: nil, long_polling_duration: nil)
    long_polling_duration ||= long_polling_duration()
    lock_duration ||= lock_duration()
    topic_details = Array(topics).map do |topic|
      { topicName: topic, lockDuration: lock_duration }
    end
    fetchAndLock workerId: worker_id, maxTasks: max_polling_tasks, asyncResponseTimeout: long_polling_duration,
                 topics: topic_details
  end

  # Returns the class name which is supposed to implement this task
  # @return [String] modularized class name of bpmn task implementation
  def task_class_name
    "#{process_definition_key}::#{activity_id}"
  end

  # Checks to make sure an implementation class is available
  # @return [Module] return class name
  # @raise [Camunda::MissingImplementationClass] if the class does not exist
  def task_class
    task_class_name.safe_constantize.tap do |klass|
      raise Camunda::MissingImplementationClass, task_class_name unless klass
    end
  end

  private

  def backtrace_cleaner
    @backtrace_cleaner ||= ActiveSupport::BacktraceCleaner.new.tap do |bc|
      Camunda::Workflow.configuration.backtrace_silencer_lines.each do |line|
        bc.add_silencer { |exception_line| exception_line =~ /#{line}/ }
      end
    end
  end

  # If the BPMN file expects a variable and the variable isn't supplied with an SubmissionError will be raised
  # indicating that the variable does not exist.
  class SubmissionError < StandardError
  end
end
