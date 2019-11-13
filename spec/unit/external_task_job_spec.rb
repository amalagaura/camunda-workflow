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
    def bpmn_perform(_variables)
      raise "This broke"
    end
  end

  let(:helper) { CamundaJob.new }
  before(:each) do
    VCR.use_cassette('external_task_job_requests') do
      @process = Camunda::ProcessDefinition.start_with_variables id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
      @task =  Camunda::ExternalTask.fetch_and_lock %w[CamundaWorkflow]
    end
  end
  let (:task) { Camunda::ExternalTask.new(activity_id: "DoSomething", process_definition_key: "CamundaWorkflow",
                                          variables: { "foo" => { "type" => "String", "value" => "bar" } }) }
  context 'process external task' do
    it 'performs jobs with success' do
      #VCR.use_cassette('perform_external_task_job') do
        results = helper.perform(task[:id], task[:variables])
        expect(results).to be_a Camunda::ExternalTask
      #end
    end
  end
end

RSpec.describe Camunda::ExternalTaskJob do
  let(:helper) { Class.new { include Camunda::ExternalTaskJob } }
  context 'process external task' do
    it 'performs job with failure' do
      #VCR.use_cassette('fails_external_task_job') do
        results = task.new.perform("Fail", {})
        expect(results[:message]).to eq("External task with id Fail does not exist")
      #end
    end
  end
end
