class Camunda::Poller
  def self.fetch_and_execute(topics, lock_duration: nil, long_polling_duration: nil)
    loop do
      Camunda::ExternalTask
        .fetch_and_lock(topics, lock_duration: lock_duration, long_polling_duration: long_polling_duration).each(&:queue_task)
    end
  end
end
