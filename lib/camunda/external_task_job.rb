##
# Camunda::ExternalTaskJob module is included in the generated bpmn_classes for ActiveJob and handles
# the task completion or failure for a given worker that has fetched work to be performed.
module Camunda::ExternalTaskJob
  # performs the external task for the process definition and processes completion or an error
  # @param [Integer] id of the worker for the fetched task
  # @param [Hash] input_variables
  def perform(id, input_variables)
    output_variables = bpmn_perform(input_variables)
    output_variables = {} if output_variables.nil?
    raise ArgumentError, "Expected a hash, got #{output_variables}" unless output_variables.is_a?(Hash)

    report_completion id, output_variables
  rescue Camunda::BpmnError => e
    report_bpmn_error id, e
  rescue StandardError => e
    report_failure id, e, input_variables
  end

  # Reports completion for an external task with output variable set in bpmn_perform
  # @param [Integer] id of the worker
  # @param [Hash] variables output variables declared in bpmn_perform
  def report_completion(id, variables)
    # Submit to Camunda using
    # POST /external-task/{id}/complete
    Camunda::ExternalTask.new(id: id).complete(variables)
  end

  # Reports external task failure to the Camunda process definition and creates an incident report
  # @param [Integer] id of the worker for the process instance
  # @param [Object] exception the exception for the failed task
  # @param [Hash] input_variables given to the process definition
  def report_failure(id, exception, input_variables)
    # Submit error state to Camunda using
    # POST /external-task/{id}/failure
    Camunda::ExternalTask.new(id: id).failure(exception, input_variables)
  end
  # Reports an error if there is a problem with bpmn_perform
  # @param [Integer] id of the process instance
  # @param [Camunda::BpmnError] exception instance of Camunda::BpmnError
  def report_bpmn_error(id, exception)
    # Submit bpmn error state to Camunda using
    # POST /external-task/{id}/bpmnError
    Camunda::ExternalTask.new(id: id).bpmn_error(exception)
  end

  # Reports a bpmn error when variables haven't been set in the bpmn_variables method of the process definition class
  def bpmn_perform(_variables)
    raise StandardError, "Please define this method which takes a hash of variables and returns a hash of variables"
  end
end
