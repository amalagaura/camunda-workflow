class Camunda::Poller
  def self.fetch_and_execute(topics, lock_duration: nil, long_polling_duration: nil)
    loop do
      Camunda::ExternalTask
        .fetch_and_lock(topics, lock_duration: lock_duration, long_polling_duration: long_polling_duration).each do |task|

        raise MissingImplementationClass, task.task_class_name unless task.task_class

        task.queue_task
      rescue StandardError => exception
        Camunda::ExternalTask.report_failure task.id, exception
        Rails.logger.error exception.full_message
        Rails.logger.error "Could not queue task #{task.id} with Activity ID: #{task.activity_id} from "\
          "Process Definition: #{task.process_definition_key}\n"\
          "We are exiting because we do not want this task executor to take tasks from the queue\n"\
          "And be unable to run them. We have marked the task as a failure."
        raise exception
      end
    end
  end

  class MissingImplementationClass < StandardError
    def initialize(class_name)
      super "Class to run a Camunda activity does not exist. Ensure there is a class with name: #{class_name} available."
    end
  end
end