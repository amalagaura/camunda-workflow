require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/object/blank'
require 'spyke'
require 'faraday'
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

  module Middleware
    class Camunda::FirstLevelParseJSON <  Faraday::Middleware
      # Taken from Her::Middleware::FirstLevelParseJSON
      # Parse the response body
      #
      # @param [String] body The response body
      # @return [Mixed] the parsed response
      # @private
      def parse(body)
        json = JSON.parse body
        if json.respond_to?(:keys)
          errors = json.delete(:errors)
          metadata = json.delete(:metadata)
        end
        error ||= {}
        metadata ||= {}
        {
          :data => json,
          :errors => errors,
          :metadata => metadata
        }
      end

      # This method is triggered when the response has been received. It modifies
      # the value of `env[:body]`.
      #
      # @param [Hash] env The response environment
      # @private
      def on_complete(env)
        str = case env[:status]
        when 204
          '{}'
        when 200
          env[:body]
        when 400..599
          env[:body] == '' ? '{}' : env[:body]
        end

        env[:body] = case env[:status]
        when 400..599
          { data: nil, metadata: {}, errors: JSON.parse(str) }
        else
          parse str
        end
      end
    end

    # Responsible for handling deserialization of variables.
    class Camunda::Middleware::SnakeCase < Faraday::Middleware
      # Check if variables are an Array or JSON and ensure variable names are transformed back from camelCase to snake_case.
      # @param env [Array,Hash]
      def on_complete(env)
        return if env[:body].blank?

        json = JSON.parse(env[:body])
        case json
        when Array
          json.map { |hash| transform_hash!(hash) }
        when Hash
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
