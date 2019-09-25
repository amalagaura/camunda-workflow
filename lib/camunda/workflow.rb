require_relative '../camunda.rb'

module Camunda
  module Workflow
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
      attr_accessor :engine_url
      attr_accessor :engine_route_prefix
      attr_accessor :cf_instance_index
      attr_accessor :lock_duration
      attr_accessor :max_polling_tasks
      attr_accessor :long_polling_duration
      attr_accessor :default_tenant_id

      def initialize
        @engine_url = 'http://localhost:8080'
        @engine_route_prefix = 'rest-engine'
        # This assumes Camunda is only called by one "application" in PCF
        @cf_instance_index = ENV['CF_INSTANCE_INDEX'].to_i
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

%w[../camunda.rb model.rb task.rb external_task.rb external_task_job.rb poller.rb process_definition.rb process_instance.rb
   deployment.rb bpmn_xml.rb]
  .each do |file|
  require File.join(__dir__, file)
end
