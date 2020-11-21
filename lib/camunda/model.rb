require 'her/model'
# This class in the main element of Her. It defines which API models will be bound to.
class Camunda::Model
  include Her::Model

  def self.log_details?
    defined?(Rails) && Rails.env.development?
  end

  # We use a lambda so that this is evaluated after Camunda::Workflow.configuration is set
  api = lambda do
    # Configuration for Her and Faraday requests and responses
    Her::API.new(url: File.join(Camunda::Workflow.configuration.engine_url)) do |c|
      c.path_prefix = Camunda::Workflow.configuration.engine_route_prefix
      # Request
      c.use Faraday::Request::Multipart
      c.use FaradayMiddleware::EncodeJson
      c.use Faraday::Request::BasicAuthentication, Camunda::Workflow.configuration.camunda_user,
            Camunda::Workflow.configuration.camunda_password
      # Response
      c.use Faraday::Response::Logger, ActiveSupport::Logger.new($stdout), bodies: true if log_details?
      c.use Her::Middleware::FirstLevelParseJSON

      c.use Her::Middleware::SnakeCase
      # Adapter
      c.adapter :net_http

      # HTTP proxy
      c.proxy = Camunda::Workflow.configuration.http_proxy if Camunda::Workflow.configuration.http_proxy
    end
  end

  use_api api

  # Returns result of find_by but raises an exception instead of returning nil
  # @param params [Hash] query parameters
  # @return [Camunda::Model]
  # @raise [Camunda::Model::RecordNotFound] if query returns no results
  def self.find_by!(params)
    find_by(params).tap do |result|
      raise Camunda::Model::RecordNotFound unless result
    end
  end

  # Returns the worker id
  # @note default worker id is set in Camunda::Workflow.configuration
  # @return [String] id of worker
  def self.worker_id
    Camunda::Workflow.configuration.worker_id
  end

  class RecordNotFound < StandardError
  end
end
