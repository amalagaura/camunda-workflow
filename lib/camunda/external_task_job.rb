# Camunda::ExternalTaskJob module is included in the generated bpmn_classes for ActiveJob and handles
# the task completion or failure for a given worker that has been locked to be performed.
# @see Camunda::ExternalTask
module Camunda::ExternalTaskJob
  # Performs the external task for the process definition and processes completion or throws an error. The below example
  # shows how to run a task based off of our generated classes from the bpmn_classes generator from the sample.bpmn file
  # provided.
  # @example
  #   task = Camunda::ExternalTask.fetch_and_lock('CamundaWorkflow').first
  #   CamundaWorkflow::DoSomething.new.perform(task.id, x: 'abcd')
  # @param id [Integer] of the worker for the locked task
  # @param input_variables [Hash]
  # @raise [Camunda::ExternalTask::SubmissionError] if Camunda does not accept the submission of the task
  def perform(id, input_variables)
    output_variables = bpmn_perform(input_variables)
    output_variables = {} if output_variables.nil?
    raise ArgumentError, "Expected a hash, got #{output_variables}" unless output_variables.is_a?(Hash)

    report_completion id, output_variables
  rescue Camunda::BpmnError => e
    report_bpmn_error id, e
  rescue Camunda::ExternalTask::SubmissionError => e
    # We re-raise this so it is not rescued below
    raise e
  rescue StandardError => e
    report_failure id, e, input_variables
  end

  # Reports completion for an external task with output variable set in bpmn_perform.
  # @param id [Integer] of the worker
  # @param variables [Hash] output variables declared in bpmn_perform
  def report_completion(id, variables)
    # Submit to Camunda using
    # POST /external-task/{id}/complete
    Camunda::ExternalTask.new(id: id).complete(variables)
  end

  # Reports external task failure to the Camunda process definition and creates an incident report
  # @param id [Integer] of the worker for the process instance
  # @param exception [Object] the exception for the failed task
  # @param input_variables [Hash] given to the process definition
  def report_failure(id, exception, input_variables)
    # Submit error state to Camunda using
    # POST /external-task/{id}/failure
    Camunda::ExternalTask.new(id: id).failure(exception, input_variables)
  end

  # Reports an error if there is a problem with bpmn_perform
  # @param id [Integer] of the process instance
  # @param exception [Camunda::BpmnError] instance of Camunda::BpmnError
  def report_bpmn_error(id, exception)
    # Submit bpmn error state to Camunda using
    # POST /external-task/{id}/bpmnError
    Camunda::ExternalTask.new(id: id).bpmn_error(exception)
  end

  # Default bpmn_perform which raises an error. Forces user to create their own implementation
  def bpmn_perform(_variables)
    raise StandardError, "Please define this method which takes a hash of variables and returns a hash of variables"
  end
end
