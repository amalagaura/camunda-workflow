require 'active_support/core_ext/string/inflections.rb'

class Camunda::ExternalTask < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'external-task'
  custom_post :fetchAndLock, :unlock

  def self.long_polling_duration
    Camunda::Workflow.configuration.long_polling_duration.in_milliseconds
  end

  def self.max_polling_tasks
    Camunda::Workflow.configuration.max_polling_tasks
  end

  def self.lock_duration
    Camunda::Workflow.configuration.lock_duration.in_milliseconds
  end

  def failure(exception, input_variables={})
    variables_information = "Input variables are #{input_variables.inspect}\n\n" if input_variables.present?
    self.class.post_raw("#{collection_path}/#{id}/failure",
                        workerId: worker_id, errorMessage: exception.message,
                        errorDetails: variables_information.to_s + exception.full_message)[:response]
  end

  def bpmn_error(bpmn_exception)
    self.class.post_raw("#{collection_path}/#{id}/bpmnError",
                        workerId: worker_id, variables: serialize_variables(bpmn_exception.variables),
                        errorCode: bpmn_exception.error_code, errorMessage: bpmn_exception.message)[:response]
  end

  def complete(variables={})
    self.class.post_raw("#{collection_path}/#{id}/complete",
                        workerId: worker_id, variables: serialize_variables(variables))[:response]
  end

  def worker_id
    self.class.worker_id
  end

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

  def queue_task
    task_class.perform_later(id, variables)
  end

  def run_now
    task_class_name.safe_constantize.perform_now id, variables
  end

  def self.fetch_and_lock(topics, lock_duration: nil, long_polling_duration: nil)
    long_polling_duration ||= long_polling_duration()
    lock_duration ||= lock_duration()
    topic_details = Array(topics).map do |topic|
      { topicName: topic, lockDuration: lock_duration }
    end
    fetchAndLock workerId: worker_id, maxTasks: max_polling_tasks, asyncResponseTimeout: long_polling_duration,
                 topics: topic_details
  end

  def task_class_name
    "#{process_definition_key}::#{activity_id}"
  end

  def task_class
    task_class_name.safe_constantize.tap do |klass|
      raise Camunda::MissingImplementationClass, task_class_name unless klass
    end
  end
end
