##
# Allows you to find created tasks by business key and complete tasks by sending a complete request
# to the Camunda engine.
class Camunda::Task < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'task'

  # @param [String] instance_business_key searches for tasks by business key
  # @param [String] task_key searches for tasks by task key (e.g. UserTask)
  def self.find_by_business_key_and_task_definition_key!(instance_business_key, task_key)
    find_by(processInstanceBusinessKey: instance_business_key, taskDefinitionKey: task_key).tap do |ct|
      unless ct
        raise MissingTask, "Could not find Camunda Task with processInstanceBusinessKey: #{instance_business_key} " \
              "and taskDefinitionKey #{task_key}"
      end
    end
  end

  # Sends a PUT request completing a user task by id
  def complete!(vars={})
    self.class.post_raw("#{self.class.collection_path}/#{id}/complete", variables: serialize_variables(vars))[:response]
        .tap do |response|
      raise MissingTask unless response.success?
    end
  end
  # Throws an error if task is missing
  class MissingTask < StandardError
  end
end
