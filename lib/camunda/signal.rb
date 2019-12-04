##
# Signal events are events which reference a named signal. Camunda::Signal is used to
# create a signal with variables.
class Camunda::Signal < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'signal'

  # @param [Hash] hash variables that are sent to Camunda engine
  # @return [Hash] empty hash is returned
  def self.create(hash={})
    hash[:variables] = serialize_variables(hash[:variables]) if hash[:variables]
    post_raw collection_path, hash
  end
end
