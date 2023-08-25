# Finds tasks by business key and task definition and allows you to report a task complete and update process variables.
# If a business key isn't supplied when creating a process definition, you can still retrieve UserTasks by using
# the `.find_by` helper.
# @see Camunda::ProcessDefinition
# @see https://github.com/remi/her
# @example
#   Camunda::Task.find_by(taskDefinitionKey: "UserTask")
# @example
#   # You can get all tasks with the `.all.each` helper
#   tasks = Camunda::Task.all.each
#   # And then complete all tasks like so
#   tasks.each(&:complete!)
class Camunda::Task < Camunda::Model
  include Camunda::VariableSerialization
  uri "task/(:id)"

  # @example
  #   user_task = Camunda::Task.find_by_business_key_and_task_definition_key!("WorkflowBusinessKey","UserTask")
  # @param instance_business_key [String] the process instance business key
  # @param task_key [String] id/key of the user task
  # @return [Camunda::Task]
  def self.find_by_business_key_and_task_definition_key!(instance_business_key, task_key)
    find_by!(processInstanceBusinessKey: instance_business_key, taskDefinitionKey: task_key)
  end

  # Complete a task and updates process variables.
  # @example
  #   user_task = Camunda::Task.find_by_business_key_and_task_definition_key!("WorkflowBusinessKey","UserTask")
  #   user_task.complete!
  # @param vars [Hash] variables to be submitted as part of task completion
  def complete!(vars={})
    self.class.request(:post, "task/#{id}/complete", variables: serialize_variables(vars))
        .tap do |response|
      raise SubmissionError, response.errors["message"] unless response.errors.blank?
    end
  end

  def bpmn_error!(error_code, error_message, vars={})
    self.class.request(:post, "task/#{id}/bpmnError", errorCode: error_code, errorMessage: error_message,
                                                      variables: serialize_variables(vars))
        .tap do |response|
      raise SubmissionError, response.errors["message"] unless response.errors.blank?
    end
  end

  def bpmn_escalation!(escalation_code, vars={})
    self.class.request(:post, "task/#{id}/bpmnEscalation", escalationCode: escalation_code,
                                                           variables: serialize_variables(vars))
        .tap do |response|
      raise SubmissionError, response.errors["message"] unless response.errors.blank?
    end
  end

  # Error class when the task cannot be submitted. For instance if the bpmn process expects a variable and the variable
  # isn"t supplied, Camunda will not accept the task
  class SubmissionError < StandardError
  end
end
