require 'spyke/base'
# This class in the main element of Her. It defines which API models will be bound to.
class Camunda::Model < Spyke::Base
  # Returns result of find_by but raises an exception instead of returning nil
  # @param params [Hash] query parameters
  # @return [Camunda::Model]
  # @raise [Camunda::Model::RecordNotFound] if query returns no results
  def self.find_by!(params)
    with(base_path).where(params).first.tap do |result|
      raise Camunda::Model::RecordNotFound unless result
    end
  end

  # Returns the worker id
  # @note default worker id is set in Camunda::Workflow.configuration
  # @return [String] id of worker
  def self.worker_id
    Camunda::Workflow.configuration.worker_id
  end

  def self.base_path
    uri.sub("(:id)", '')
  end

  class RecordNotFound < StandardError
  end
end
