class Camunda::Signal < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'signal'

  def self.send_signal(vars={})
    create name: vars[:name], variables: serialize_variables(vars[:variables])
  end
end
