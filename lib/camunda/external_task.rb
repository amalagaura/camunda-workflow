require 'active_support/core_ext/string/inflections.rb'
##
# External Task is created and then added to a topic. ExternalTask queries the topic and locks the task. After the task is locked,
# the application can work on it and complete it. Below is an excerpt from the Camunda documentation regarding
# the ExternalTask process.
# @see https://docs.camunda.org/manual/7.7/user-guide/process-engine/external-tasks/
# "When the process engine encounters a service task that is configured to be externally handled, it creates an external task
# instance and adds it to a list of external tasks(step 1). The task instance receives a topic that identifies the nature of
# the work to be performed. At a time in the future, an external worker may fetch and lock tasks for a specific set of
# topics (step2). To prevent one task being fetched by multiple workers at the same time, a task has a timestamp-based lock
# that is set when the task is acquired. Only when the lock expires, another worker can fetch the task again. When an external
# worker has completed the desired work, it can signal the process engine to continue process execution after the service
# task (step 3)."
class Camunda::ExternalTask < Camunda::Model
  # VeriableSerialization is included to transform variables from snake_case to camelCase
  include Camunda::VariableSerialization
  # collection_path sets the path for Her in Camunda::Model
  collection_path 'external-task'
  custom_post :fetchAndLock, :unlock

  # @return [Integer] default polling duration from Camunda::Workflow configuration
  def self.long_polling_duration
    Camunda::Workflow.configuration.long_polling_duration.in_milliseconds
  end

  # @return [Integer] sets the max polling tasks to 2
  def self.max_polling_tasks
    Camunda::Workflow.configuration.max_polling_tasks
  end

  # @return [Integer] default lock duration from Camunda::Workflow configuration
  def self.lock_duration
    Camunda::Workflow.configuration.lock_duration.in_milliseconds
  end

  def failure(exception, input_variables={})
    variables_information = "Input variables are #{input_variables.inspect}\n\n" if input_variables.present?
    self.class.post_raw("#{collection_path}/#{id}/failure",
                        workerId: worker_id, errorMessage: exception.message,
                        errorDetails: variables_information.to_s + exception.full_message)[:response]
  end

  # @param [Hash] bpmn_exception
  def bpmn_error(bpmn_exception)
    self.class.post_raw("#{collection_path}/#{id}/bpmnError",
                        workerId: worker_id, variables: serialize_variables(bpmn_exception.variables),
                        errorCode: bpmn_exception.error_code, errorMessage: bpmn_exception.message)[:response]
  end

  # @param [Object] variables
  def complete(variables={})
    self.class.post_raw("#{collection_path}/#{id}/complete",
                        workerId: worker_id, variables: serialize_variables(variables))[:response]
  end

  # @return [String] returns the worker ID, default is set to '0' in Camunda::Workflow.configuration
  def worker_id
    self.class.worker_id
  end

  # @return [String]
  def collection_path
    self.class.collection_path
  end

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
  def queue_task
    task_class.perform_later(id, variables)
  end

  # Runs the task using ActiveJob based on the classes created by bpmn_classes_generator.
  def run_now
    task_class_name.safe_constantize.perform_now id, variables
  end
  # Locking means that the task is reserved for this worker for a certain duration beginning with the time of fetching and
  # prevents that another worker can fetch the same task while the lock is valid. Locking duration is set in the the
  # Camunda::Workflow configuration.

  # @param [Array<String>] topics
  # @param [Integer] lock_duration
  # @param [Integer] long_polling_duration
  def self.fetch_and_lock(topics, lock_duration: nil, long_polling_duration: nil)
    long_polling_duration ||= long_polling_duration()
    lock_duration ||= lock_duration()
    topic_details = Array(topics).map do |topic|
      { topicName: topic, lockDuration: lock_duration }
    end
    fetchAndLock workerId: worker_id, maxTasks: max_polling_tasks, asyncResponseTimeout: long_polling_duration,
                 topics: topic_details
  end

  # Returns the class name of the process definition
  # @return [String] class name of definition
  def task_class_name
    "#{process_definition_key}::#{activity_id}"
  end

  # Checks to make sure an implementation class is available, if the class hasn't been created, an error is thrown
  # @return [Module] return class name
  def task_class
    task_class_name.safe_constantize.tap do |klass|
      raise Camunda::MissingImplementationClass, task_class_name unless klass
    end
  end
end
