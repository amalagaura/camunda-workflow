require 'camunda/workflow'
require 'camunda/model'
require 'camunda/external_task'
require 'camunda/external_task_job'
RSpec.describe Camunda::ExternalTaskJob do
  class CamundaJob
    include Camunda::ExternalTaskJob
    def bpmn_perform(_variables)
      { year: '2019', month: 'October' }
    end
  end

  class CamundaJobWithFailure
    include Camunda::ExternalTaskJob
    # def bpmn_perform(_variables)
    # raise "This broke"
    # end
  end

  let(:helper) { CamundaJob.new }
  before(:each) do
    VCR.use_cassette('external_task_job_requests') do
      @process = Camunda::ProcessDefinition.start_with_variables id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
      @task =  Camunda::ExternalTask.fetch_and_lock %w[CamundaWorkflow]
    end
  end
  # let(:tasks) { [Camunda::ExternalTask.new()]}
  let(:task) { Camunda::ExternalTask.new(id: 1234, variables: { "foo" => { "type" => "String", "value" => "bar" } }) }
  context 'process external task' do
    it 'performs jobs with success' do
      VCR.use_cassette('perform_external_task_job') do
        results = helper.perform(@task[0][:id], @task[0][:variables])
        expect(results).to be_a Camunda::ExternalTask
      end
    end
  end
end

RSpec.describe Camunda::ExternalTaskJob do
  let(:task) { Camunda::ExternalTask.new(worker_id: 34, id: 1234, variables: { "foo" => { "type" => "String", "value" => "bar" } }) }
  let(:helper) { CamundaJobWithFailure.new }
  context 'process external task' do
    it 'fails with wrong id' do
      results = helper.perform(task[:id], task[:variables])
      expect(results[:message]).to eq("External task with id 1234 does not exist")
    end
    it 'fails bpmn_perform' do
      expect { helper.bpmn_perform(task[:variables]) }.to raise_error(StandardError)
    end
  end
end
