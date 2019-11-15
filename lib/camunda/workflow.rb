module Camunda
  module Workflow
    def self.configure
      yield(configuration)
    end

    def self.configuration
      @configuration ||= Configuration.new
    end

    class Configuration
      attr_accessor :engine_url
      attr_accessor :engine_route_prefix
      attr_accessor :worker_id
      attr_accessor :lock_duration
      attr_accessor :max_polling_tasks
      attr_accessor :long_polling_duration
      attr_accessor :default_tenant_id

      def initialize
        @engine_url = 'http://localhost:8080'
        @engine_route_prefix = 'rest-engine'
        # This assumes Camunda is only called by one "application" in PCF
        @worker_id = nil
        @lock_duration = 14.days
        @max_polling_tasks = 2
        @long_polling_duration = 30.seconds
        @default_tenant_id =
          if defined?(Rails)
            Rails.env.test? ? 'test-environment' : nil
          end
      end
    end
  end
end

%w[../camunda.rb variable_serialization.rb model.rb task.rb external_task.rb external_task_job.rb poller.rb process_definition.rb
   process_instance.rb deployment.rb signal.rb bpmn_xml.rb]
  .each do |file|
  require File.join(__dir__, file)
end
