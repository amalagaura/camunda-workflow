module Camunda
  ##
  # Default configuration file for camunda-workflow. These defaults can be overridden using an
  # initializer file within a Rails application.
  # @example override default values
  #   Camunda::Workflow.configure do |config|
  #     config.engine_url = 'http://localhost:8080'
  #     config.engine_route_prefix = 'rest'
  #   end
  module Workflow
    def self.configure
      yield(configuration)
    end

    # Implements Configuration class and sets default instance variables. The default variables can be overridden by creating an
    # initializer file within your rails application and setting the variables like in the example below.
    # @note if HTTP Basic Auth is used with the Camunda engine, this is where you would set a camunda_user and camunda_password
    # using the creditials from a user setup in Camunda Admin.
    # @example
    #   'Camunda::Workflow.configure do |config|
    #     config.engine_url = 'http://localhost:8080'
    #     config.engine_route_prefix = 'rest'
    #   end'
    def self.configuration
      @configuration ||= Configuration.new
    end
    # Default instance variables configurations for Her and camunda-workflow
    class Configuration
      # Sets the deult engine url for Camunda REST Api
      # @return [String] the url for Camunda deployment
      attr_accessor :engine_url
      # Engine route prefix that determines the path for the REST Api
      # Default route for Java spring app is `/rest`
      # Default route for Camunda deployment is `/rest-engine`
      # @return [String] the prefix for Camunda REST Api
      attr_accessor :engine_route_prefix
      attr_accessor :worker_id
      # The defult fetch_and_lock time duration when fetching a task
      # @return [Integer] time in days to lock task
      attr_accessor :lock_duration
      # Max polling tasks when using the command line to fetch and lock tasks
      # @return [Integer] default is set to fetch and lock 2 tasks
      attr_accessor :max_polling_tasks
      # With the aid of log polling, a request is suspended by the server if no external tasks are available.
      # Long polling significantly reduces the number of request and enables using resources more
      # efficiently on both the server and client.
      attr_accessor :long_polling_duration
      # The tenant identifier is specified on the deployment and is propagated to all data
      # that is created from the deployment(e.g. process definitions, process instances, tacks).
      # @return [String] name for tenant identifier
      attr_accessor :tenant_id
      # When HTTP Basic Auth is turned on for Camunda, a user needs to be created in Camunda Admin
      # and set in to be used in the configuration.
      # @return [String] Camunda user name for HTTP Basic Auth
      attr_accessor :camunda_user
      # Camunda password is supplied with the Camunda user to authenticate using HTTP Basic Auth.
      # @return [String] Camunda password for HTTP Basic Auth
      attr_accessor :camunda_password

      def initialize
        @engine_url = 'http://localhost:8080'
        @engine_route_prefix = 'rest-engine'
        @camunda_user = ''
        @camunda_password = ''
        @worker_id = '0'
        @lock_duration = 14.days
        @max_polling_tasks = 2
        @long_polling_duration = 30.seconds
        @tenant_id = if defined?(Rails)
                       Rails.env.test? ? 'test-environment' : nil
                     end
      end
    end
  end
end

%w[../camunda.rb variable_serialization.rb model.rb task.rb external_task.rb external_task_job.rb poller.rb process_definition.rb
   process_instance.rb deployment.rb signal.rb bpmn_xml.rb incident.rb]
  .each do |file|
  require File.join(__dir__, file)
end
