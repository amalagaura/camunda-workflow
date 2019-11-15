require 'camunda/workflow'
require 'camunda/task'

RSpec.describe Camunda::Task do
  let(:tasks) { Camunda::Task.all }
  before(:each) do
    VCR.use_cassette 'create_process_definition_for_user_task' do
      Camunda::ProcessDefinition.start id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
    end
  end
  context 'mark user tasks completed' do
    it 'marks tasks complete by business id and task id' do
      VCR.use_cassette('mark_task_complete') do
        completed_tasks = tasks.each { Camunda::Task.mark_task_completed! "WorkflowBusinessTask", "UserTask", {} }
        expect(completed_tasks).to be_an(Array)
      end
    end

    it 'finds user task by business key and task definition' do
      VCR.use_cassette('find_user_task_by_business_key') do
        find_tasks = tasks.each { Camunda::Task.find_by_business_key_and_task_definition_key! "WorkflowBusinessTask", "UserTask" }
        expect(find_tasks).to be_an(Array)
      end
    end
    it 'fails user task by business key and task definition' do
      VCR.use_cassette('fail_user_task_by_business_key') do
        expect { Camunda::Task.find_by_business_key_and_task_definition_key! "UnknownBusinessKey", "UnknownTask" }.to raise_error
      end
    end
  end
end
