require 'active_support/core_ext/string/inflections.rb'
require 'active_support/core_ext/object/blank.rb'
require 'her'
require 'faraday'
require 'faraday_middleware'

module Camunda
  # Camunda class
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end
  ##
  # Responsible for handling deserialization of variables
  class Her::Middleware::SnakeCase < Faraday::Response::Middleware
    # Check if variables are an Array or JSON and ensure variables are transformed back from camelCase to snake_case.
    # @param [Array/Hash] env
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

    # method that transforms CamelCase to snake_case
    def transform_hash!(hash)
      hash.deep_transform_keys!(&:underscore)
    end
  end
  # Raises error when Camunda bpmn task does not exist.
  class MissingImplementationClass < StandardError
    def initialize(class_name)
      super "Class to run a Camunda activity does not exist. Ensure there is a class with name: #{class_name} available."
    end
  end
  # Raises error when deployment of process definition fails.
  class ProcessEngineException < StandardError
  end
  # Raises error when an error occurs within the bpmn tasks class
  class BpmnError < StandardError
    attr_reader :error_code, :variables
    # @param [String] message
    # @param [String] error_code
    # @param [Object] variables
    def initialize(message:, error_code:, variables: {})
      super(message)
      @error_code = error_code
      @variables = variables
    end
  end
end
