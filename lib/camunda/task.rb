class Camunda::Task < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'task'
  custom_post :complete

  def self.find_by_business_key_and_task_definition_key!(instance_business_key, task_key)
    find_by(instanceBusinessKey: instance_business_key, taskDefinitionKey: task_key).tap do |ct|
      unless ct
        raise "Could not find Camunda Task with processInstanceBusinessKey: #{instance_business_key} " \
              "and taskDefinitionKey #{task_key}"
      end
    end
  end

  def self.mark_task_completed!(instance_business_key, task_key, variables = {})
    find_by_business_key_and_task_definition_key!(instance_business_key, task_key).tap do |ct|
      complete id: ct.id, variables: serialize_variables(variables)
    end
  end
end
