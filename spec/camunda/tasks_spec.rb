RSpec.describe Camunda::Task, :vcr do
  let(:business_key) { 'WorkflowBusinessKey' }
  let(:task_key) { "UserTask" }
  let(:result) { task.complete! }

  before { Camunda::ProcessDefinition.start_by_key definition_key, businessKey: business_key }

  # Creating a method instead of a let() because it has to be re-evaluated
  def task
    Camunda::Task.find_by_business_key_and_task_definition_key! business_key, task_key
  end
  describe 'mark user tasks completed' do
    it('can mark task complete') do
      expect(result).to be_success
      expect { task }.to raise_error(Camunda::Model::RecordNotFound)
    end
  end

  describe 'user task with error' do
    let(:task_key) { "UserTaskForError" }

    it('bpmn error in submitting gives an error description') do
      expect { result }
        .to raise_error(
          Camunda::Task::SubmissionError,
          /Unknown property used in expression: \${missingVariable}. Cause: Cannot resolve identifier 'missingVariable'/
        )
    end
  end

  describe 'unknown task key' do
    let(:find_task) { described_class.find_by_business_key_and_task_definition_key! business_key, "Unknown" }

    it('cannot find without task_key') { expect { find_task }.to raise_error(Camunda::Model::RecordNotFound) }
  end

  describe 'unknown business key' do
    let(:find_task) { described_class.find_by_business_key_and_task_definition_key! "Unknown", task_key }

    it('cannot mark complete') { expect { find_task }.to raise_error(Camunda::Model::RecordNotFound) }
  end
end
