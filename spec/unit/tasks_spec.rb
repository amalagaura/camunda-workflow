RSpec.describe Camunda::Task, :vcr, :deployment do
  context 'mark user tasks completed' do
    before { Camunda::ProcessDefinition.start_by_key 'CamundaWorkflow', businessKey: 'WorkflowBusinessKey' }
    let(:subject) { Camunda::Task.mark_task_completed! "WorkflowBusinessTask", "UserTask", {} }

    it('can mark task complete') do
      is_expected.to be_success
      expect { Camunda::Task.find_by_business_key_and_task_definition_key! "WorkflowBusinessKey", "UserTask" }
        .to raise_error(Camunda::Task::MissingTask)
    end
  end
  context 'unknown task' do
    let(:subject) { Camunda::Task.mark_task_completed! "Unknown", "Unknown", {} }
    it('cannot mark complete') { expect { subject }.to raise_error(Camunda::Task::MissingTask) }
  end
end
