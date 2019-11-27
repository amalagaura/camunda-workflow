RSpec.describe Camunda::Task, :vcr, :deployment do
  let(:business_key) { 'WorkflowBusinessKey' }
  let(:task_key) { "UserTask" }
  before { Camunda::ProcessDefinition.start_by_key definition_key, businessKey: business_key }

  # Creating a method instead of a let() because it has to be re-evaluated
  def task
    Camunda::Task.find_by_business_key_and_task_definition_key! business_key, task_key
  end
  context 'mark user tasks completed' do
    let(:subject) { task.complete! }
    it('can mark task complete') do
      is_expected.to be_success
      expect { task }.to raise_error(Camunda::Task::MissingTask)
    end
  end
  context 'unknown task key' do
    let(:subject) { Camunda::Task.find_by_business_key_and_task_definition_key! business_key, "Unknown" }
    it('cannot find without task_key') { expect { subject }.to raise_error(Camunda::Task::MissingTask) }
  end
  context 'unknown business key' do
    let(:subject) { Camunda::Task.find_by_business_key_and_task_definition_key! "Unknown", task_key }
    it('cannot mark complete') { expect { subject }.to raise_error(Camunda::Task::MissingTask) }
  end
end
