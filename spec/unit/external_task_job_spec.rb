RSpec.describe Camunda::ExternalTaskJob do
  class CamundaJob
    include Camunda::ExternalTaskJob
    def bpmn_perform(_variables)
      { year: '2019', month: 'October' }
    end
  end

  class CamundaJobWithFailure
    include Camunda::ExternalTaskJob
    def bpmn_perform(_variables)
      raise StandardError, "This broke"
    end
  end

  class CamundaJobNoBpmnPerformMethod
    include Camunda::ExternalTaskJob
  end

  let(:fail_task) do
    Camunda::ExternalTask.new(activity_id: "NoClass", process_definition_key: "NoWorkflow", variables: {})
  end

  let(:task) do
    Camunda::ExternalTask.new(worker_id: 34, id: 1234,
                              variables: { "foo" => { "type" => "String", "value" => "bar" } })
  end
  let(:helper) { CamundaJob.new }
  let(:helper_fail) { CamundaJobWithFailure.new }
  let(:bpmn) { CamundaJobNoBpmnPerformMethod.new }

  let!(:process) { Camunda::ProcessDefinition.start id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'Key' }
  let!(:task) { Camunda::ExternalTask.fetch_and_lock %w[CamundaWorkflow] }

  before(:each) do
    process
    task
  end

  context 'process external task', :vcr do
    it 'performs jobs with success' do
      results = helper.perform(task[0][:id], task[0][:variables])
      expect(results).to be_a Camunda::ExternalTask
    end
  end

  it 'raises error in from CamundaJobFailure bpmn_perform' do
    response = helper_fail.perform(task[0][:id], task[0][:variables])
    expect(response[:parsed_data][:data]).to eq({})
    expect(response[:response].status).to eq(204)
  end

  it 'no bpmn class available for output variables' do
    response = bpmn.perform(task[0][:id], task[0][:variables])
    expect(response[:parsed_data][:data]).to eq({})
    expect(response[:response].status).to eq(204)
  end
end
