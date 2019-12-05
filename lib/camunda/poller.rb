# The poller will run as an infinite loop with long polling to fetch tasks, queue, and run them.
# Topic is the process definition key. Below will run the poller to fetch, lock, and run a task for the
# example process definition with an id of CamundaWorkflow.
# @example
#   Camunda::Poller.fetch_and_execute %w[CamundaWorkflow]
class Camunda::Poller
  # @param [Array] topics process definition keys
  # @param [Integer] lock_duration lock duration time, default time is set in Camunda::Workflow.configuration
  # @param [Integer] long_polling_duration long polling time, default is set to Camunda::Workflow.configuration
  def self.fetch_and_execute(topics, lock_duration: nil, long_polling_duration: nil)
    loop do
      Camunda::ExternalTask
        .fetch_and_lock(topics, lock_duration: lock_duration, long_polling_duration: long_polling_duration).each do |task|
        task.queue_task
      rescue Camunda::MissingImplementationClass => e
        task.failure(e)
      end
    end
  end
end
