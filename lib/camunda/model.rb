require 'her/model'
require 'faraday'
require 'faraday_middleware'

class Camunda::Model
  include Her::Model

  api = lambda do
    Her::API.new(url: File.join(Camunda::Workflow.configuration.engine_url)) do |c|
      c.path_prefix = Camunda::Workflow.configuration.engine_route_prefix
      # Request
      c.use Faraday::Request::Multipart
      c.use FaradayMiddleware::EncodeJson
      # Response
      c.use Faraday::Response::Logger, ActiveSupport::Logger.new(STDOUT), bodies: true if Rails.env.development?
      c.use Her::Middleware::FirstLevelParseJSON

      c.use Her::Middleware::SnakeCase
      # Adapter
      c.adapter :net_http
    end
  end

  use_api api

  def self.worker_id
    Camunda::Workflow.configuration.cf_instance_index
  end
end
