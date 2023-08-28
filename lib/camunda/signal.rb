##
# Signal events are events which reference a named signal. Camunda::Signal is used to
# create a signal with variables.
# @example
#    `Camunda::Signal.create name: 'Signal Name', variables: {foo: "bar"}`
class Camunda::Signal < Camunda::Model
  include Camunda::VariableSerialization
  uri 'signal/(:id)'
  # Creates a signal within the process definition on the Camunda engine
  # @param hash [Hash] variables that are sent to Camunda engine
  # @return [{Symbol => Hash,Faraday::Response}]
  def self.create(hash={})
    hash[:variables] = serialize_variables(hash[:variables]) if hash[:variables]
    request :post, 'signal', hash
  end
end
