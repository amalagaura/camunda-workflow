module Camunda::ExternalTaskJob
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

  def report_completion(id, variables)
    # Submit to Camunda using
    # POST /external-task/{id}/complete
    Camunda::ExternalTask.new(id: id).complete(variables)
  end

  def report_failure(id, exception, input_variables)
    # Submit error state to Camunda using
    # POST /external-task/{id}/failure
    Camunda::ExternalTask.new(id: id).failure(exception, input_variables)
  end

  def report_bpmn_error(id, exception)
    # Submit bpmn error state to Camunda using
    # POST /external-task/{id}/bpmnError
    Camunda::ExternalTask.new(id: id).bpmn_error(exception)
  end

  def bpmn_perform(_variables)
    raise StandardError, "Please define this method which takes a hash of variables and returns a hash of variables"
  end
end
