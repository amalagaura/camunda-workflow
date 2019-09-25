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

  class Her::Middleware::SnakeCase < Faraday::Response::Middleware
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

    def transform_hash!(hash)
      hash.deep_transform_keys!(&:underscore)
    end
  end

  class ProcessEngineException < StandardError
  end
end
