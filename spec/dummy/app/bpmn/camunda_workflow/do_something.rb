module CamundaWorkflow
  class DoSomething < CamundaJob
    include CamundaWorkflow

    def bpmn_perform(_variables)
      hash = {year: '2019', month: 'October'}
      hash
    end

  end
end
