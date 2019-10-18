class Camunda::ProcessDefinition < Camunda::Model
  include Camunda::VariableSerialization

  # We are going to cheat and only use the key. We will not be able to use the UUID. With Her we would need another class
  collection_path 'process-definition/key'
  primary_key :id
  custom_post :start

  def self.start_with_variables(hash)
    hash[:variables] = serialize_variables(hash[:variables]) if hash[:variables]
    start hash
  end
end
