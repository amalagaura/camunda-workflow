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

  let(:helper) { CamundaJob.new }
  before(:each) do
    VCR.use_cassette('external_task_job_requests') do
      @process = Camunda::ProcessDefinition.start_with_variables id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
      @task =  Camunda::ExternalTask.fetch_and_lock %w[CamundaWorkflow]
    end
  end
  context 'process active job' do
    it 'performs jobs with success' do
      VCR.use_cassette('perform_external_task_job') do
        results = helper.perform(@task[0][:id], @task[0][:variables])
        expect(results).to be_a Camunda::ExternalTask
      end
    end
  end
end

RSpec.describe Camunda::ExternalTaskJob do
  let(:helper) { Class.new { include Camunda::ExternalTaskJob } }
  context 'process active job' do
    it 'performs job with failure' do
      VCR.use_cassette('fails_external_task_job') do
        results = helper.new.perform("Fail", {})
        expect(results[:message]).to eq("External task with id Fail does not exist")
      end
    end
  end
end
