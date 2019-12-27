require 'active_support/core_ext/string/inflections.rb'
require 'active_support/core_ext/object/blank.rb'
require 'her'
require 'faraday'
require 'faraday_middleware'
require 'camunda/railtie' if defined?(Rails)
# Top level module for camunda-workflow.
module Camunda
  # Camunda class
  class << self
    # Allows setting the logger to a custom logger
    attr_writer :logger
    # Default is output to the standard output stream.
    # @return [Object] instance which is used for logging
    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end
  ##
  # Responsible for handling deserialization of variables.
  class Her::Middleware::SnakeCase < Faraday::Response::Middleware
    # Check if variables are an Array or JSON and ensure variable names are transformed back from camelCase to snake_case.
    # @param env [Array,Hash]
    def on_complete(env)
      return if env[:body].blank?

      json = JSON.parse(env[:body])
      if json.is_a?(Array)
        json.map { |hash| transform_hash!(hash) }
      elsif json.is_a?(Hash)
        transform_hash!(json)
      end
      env[:body] = JSON.generate(json)
    end

    private

    # Return a new hash with all keys converted by the block operation.
    def transform_hash!(hash)
      hash.deep_transform_keys!(&:underscore)
    end
  end
  # Error when class corresponding to Camunda bpmn task does not exist.
  class MissingImplementationClass < StandardError
    # Initializes message for MissingImplementationClass
    def initialize(class_name)
      super "Class to run a Camunda activity does not exist. Ensure there is a class with name: #{class_name} available."
    end
  end
  # Error when deployment of process definition fails.
  class ProcessEngineException < StandardError
  end
  # Error when BPMN process cannot be deployed.
  class BpmnError < StandardError
    # Camunda BPMN error code
    # @return [String]
    attr_reader :error_code
    # variables to send to Camunda along with the error
    # @return [Hash]
    attr_reader :variables

    # @param message [String]
    # @param error_code [String]
    # @param variables [Hash]
    def initialize(message:, error_code:, variables: {})
      super(message)
      @error_code = error_code
      @variables = variables
    end
  end
end
