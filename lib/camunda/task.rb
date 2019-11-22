class Camunda::Task < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'task'

  def self.find_by_business_key_and_task_definition_key!(instance_business_key, task_key)
    find_by(instanceBusinessKey: instance_business_key, taskDefinitionKey: task_key).tap do |ct|
      unless ct
        raise MissingTask, "Could not find Camunda Task with processInstanceBusinessKey: #{instance_business_key} " \
              "and taskDefinitionKey #{task_key}"
      end
    end
  end

  def self.mark_task_completed!(instance_business_key, task_key, variables={})
    ct = find_by_business_key_and_task_definition_key!(instance_business_key, task_key)
    ct.complete! variables
  end

  def complete!(vars)
    self.class.post_raw("#{self.class.collection_path}/#{id}/complete", variables: serialize_variables(vars))[:response]
        .tap do |response|
      raise MissingTask unless response.success?
    end
  end

  class MissingTask < StandardError
  end
end
