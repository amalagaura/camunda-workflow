require 'active_support/core_ext/string/inflections.rb'
require 'active_support/core_ext/object/blank.rb'

module Camunda
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end
  end

  class Her::Middleware::SnakeCamelCase < Faraday::Response::Middleware
    def call(request_env)
      # do something with the request. Transform response to camel case
      request_env[:body] = transform(request_env[:body], camelcase_transform) if request_env[:body].present?
      @app.call(request_env).on_complete do |response_env|
        # do something with the response. Transform response to underscore case
        response_env[:body] = transform(response_env[:body], underscore_transform) if response_env[:body].present?
      end
    end

    def underscore_transform
      proc do |hash|
        hash.deep_transform_keys!(&:underscore)
      end
    end

    def camelcase_transform
      proc do |hash|
        hash.deep_transform_keys! { |key| key.camelcase(:lower) }
      end
    end

    def transform(body, key_transformer)
      json = JSON.parse(body)
      if json.is_a?(Array)
        json.map { |hash| key_transformer.call(hash) }
      elsif json.is_a?(Hash)
        key_transformer.call(json)
      end
      JSON.generate(json)
    end
  end

  class ProcessEngineException < StandardError
  end
end
