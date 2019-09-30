require 'active_support/core_ext/string/inflections.rb'

class Camunda::ExternalTask < Camunda::Model
  collection_path 'external-task'
  custom_post :fetchAndLock, :unlock, :complete, :failure

  def self.long_polling_duration
    Camunda::Workflow.configuration.long_polling_duration.in_milliseconds
  end

  def self.max_polling_tasks
    Camunda::Workflow.configuration.max_polling_tasks
  end

  def self.lock_duration
    Camunda::Workflow.configuration.lock_duration.in_milliseconds
  end

  # rubocop:disable Metrics/MethodLength
  def self.serialize_variables(variables)
    hash = variables.transform_values do |value|
      case value
      when String
        { value: value, type: 'String' }
      when Array, Hash
        { value: transform_json(value).to_json, type: 'Json' }
      when TrueClass, FalseClass
        { value: value, type: 'Boolean' }
      when Integer
        { value: value, type: 'Integer' }
      when Float
        { value: value, type: 'Double' }
      else
        raise ArgumentError, "Not supporting complex types yet"
      end
    end
    camelcase_keys(hash)
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/CyclomaticComplexity

  def self.transform_json(json)
    if json.is_a?(Array)
      json.map { |element| transform_json(element) }
    elsif json.is_a?(Hash)
      camelcase_keys(json)
    else
      json
    end
  end

  def self.camelcase_keys(hash)
    hash.deep_transform_keys { |key| key.to_s.camelcase(:lower) }
  end

  def self.report_failure(id, exception, input_variables)
    variables_information = "Input variables are #{input_variables.inspect}\n\n"
    failure workerId: worker_id, id: id, errorMessage: exception.message,
            errorDetails: variables_information + exception.full_message
  end

  def report_failure(exception)
    self.class.report_failure id, exception, variables
  end

  def self.complete_task(id, variables = {})
    complete workerId: worker_id, id: id, variables: serialize_variables(variables)
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
    task_class_name.safe_constantize
  end
end
