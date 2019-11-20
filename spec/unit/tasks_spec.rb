RSpec.describe Camunda::Task do
  let(:tasks) { Camunda::Task.all }
  before do
    Camunda::ProcessDefinition.start id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
  end
  context 'mark user tasks completed', :vcr do
    it 'marks tasks complete by business id and task id' do
      completed_tasks = tasks.each { Camunda::Task.mark_task_completed! "WorkflowBusinessTask", "UserTask", {} }
      expect(completed_tasks).to be_an(Array)
    end

    it 'finds user task by business key and task definition' do
      find_tasks = tasks.each { Camunda::Task.find_by_business_key_and_task_definition_key! "WorkflowBusinessTask", "UserTask" }
      expect(find_tasks).to be_an(Array)
    end
    it 'fails user task by business key and task definition' do
      expect { Camunda::Task.find_by_business_key_and_task_definition_key! "UnknownBusinessKey", "UnknownTask" }
        .to raise_error(Camunda::Task::MissingTask)
    end
  end
end
