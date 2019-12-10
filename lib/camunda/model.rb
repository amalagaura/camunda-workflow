require 'her/model'
# This class in the main element of Her. It defines which API models will be bound to.
class Camunda::Model
  include Her::Model

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
      c.use Faraday::Response::Logger, ActiveSupport::Logger.new(STDOUT), bodies: true if Rails.env.development?
      c.use Her::Middleware::FirstLevelParseJSON

      c.use Her::Middleware::SnakeCase
      # Adapter
      c.adapter :net_http
    end
  end

  use_api api
  # Returns the worker id
  # @note default worker id is set in Camunda::Workflow.configuration
  # @return [String] id of worker
  def self.worker_id
    Camunda::Workflow.configuration.worker_id
  end
end
