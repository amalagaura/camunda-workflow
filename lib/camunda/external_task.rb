module Camunda
  class ExternalTask < Camunda::Model
    collection_path '/engine-rest/external-task'
    custom_post :fetchAndLock, :unlock, :complete, :failure

    def self.max_tasks
      5
    end

    def self.lock_duration
      1.hour.in_milliseconds
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def self.serialize_variables(variables)
      variables.transform_values do |value|
        case value
        when String
          { value: value, type: 'String' }
        when Array
          { value: value.to_json, type: 'Json' }
        when Hash
          { value: value.to_json, type: 'Json' }
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
    end
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity

    def self.report_failure(id, exception)
      failure workerId: worker_id, id: id, errorMessage: exception.message, errorDetails: exception.full_message
    end

    def self.complete_task(id, variables = {})
      complete workerId: worker_id, id: id, variables: serialize_variables(variables)
    end

    def variables
      super.transform_values do |details|
        if details['value_info'] == 'Json'
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
      fetchAndLock workerId: worker_id, maxTasks: max_tasks, asyncResponseTimeout: long_polling_duration, topics: topic_details
    end

    def task_class_name
      "#{process_definition_key}::#{activity_id}"
    end

    def task_class
      task_class_name.safe_constantize
    end
  end
end
