class Camunda::ProcessInstance < Camunda::Model
  collection_path 'process-instance'
  custom_get :variables
end
