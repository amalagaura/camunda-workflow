class Camunda::Task < Camunda::Model
  collection_path 'task'
  custom_post :complete
end
