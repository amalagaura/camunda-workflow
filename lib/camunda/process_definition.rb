class Camunda::ProcessDefinition < Camunda::Model
  # We are going to cheat and only use the key. We will not be able to use the UUID. With Her we would need another class
  collection_path 'process-definition/key'
  primary_key :id
  custom_post :start
end
