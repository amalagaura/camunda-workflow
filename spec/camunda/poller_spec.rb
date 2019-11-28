RSpec.describe Camunda::Poller, :vcr, :deployment do
  describe 'start the poller' do
    let(:task_instance) { instance_double(Camunda::ExternalTask) }

    before do
      Camunda::ProcessDefinition.start_by_key definition_key, variables: { x: 'abcd' }, businessKey: 'Key'
      allow(Camunda::ExternalTask).to receive(:new).and_return(task_instance)
      allow(task_instance).to receive(:clear_changes_information)
      allow(task_instance).to receive(:run_callbacks)
    end

    # rubocop:disable RSpec/MessageSpies
    # We are testing code in an infinite loop so we have to stub the loop
    it '#fetch_and_execute' do
      expect(described_class).to receive(:loop).and_yield

      expect(task_instance).to receive(:queue_task).and_return('something')
      described_class.fetch_and_execute(%w[CamundaWorkflow])
    end
    # rubocop:enable RSpec/MessageSpies
  end
end
