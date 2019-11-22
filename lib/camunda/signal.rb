class Camunda::Signal < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'signal'

  def self.create(hash={})
    hash[:variables] = serialize_variables(hash[:variables]) if hash[:variables]
    post_raw collection_path, hash
  end
end
