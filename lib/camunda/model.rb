require 'her/model'
class Camunda::Model
  include Her::Model
  her_api = Her::API.new(url: "http://localhost:8080/engine-rest") do |c|
    # Request
    c.use FaradayMiddleware::EncodeJson
    # Response
    c.use Faraday::Response::Logger, ActiveSupport::Logger.new(STDOUT), bodies: true if Rails.env.development?
    c.use Her::Middleware::FirstLevelParseJSON
    c.use Her::Middleware::SnakeCase
    # Adapter
    c.use Faraday::Adapter::NetHttp
  end
  use_api her_api

  def self.worker_id
    # This assumes Camunda is only called by one "application" in PCF
    ENV['CF_INSTANCE_INDEX'].to_i
  end

  def self.long_polling_duration
    1.minute.in_milliseconds
  end
end
