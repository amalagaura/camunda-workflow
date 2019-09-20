module Camunda::ExternalTaskJob
  def perform(id, input_variables)
    output_variables = bpmn_perform(input_variables)

    report_completion id, output_variables
  rescue StandardError => e
    report_failure id, e
  end

  def report_completion(id, variables)
    # Submit to Camunda using
    # POST /external-task/{id}/complete
    Camunda::ExternalTask.complete_task(id, variables)
  end

  def report_failure(id, exception)
    # Submit error state to Camunda using
    # POST /external-task/{id}/failure
    Camunda::ExternalTask.report_failure(id, exception)
  end

  def bpmn_perform(_variables)
    raise StandardError, "Please define this method which takes a hash of variables and returns a hash of variables"
  end
end
