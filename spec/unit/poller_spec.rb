RSpec.describe Camunda::Poller, :vcr, :deployment do
  context 'start the poller' do
    before do
      Camunda::ProcessDefinition.start_by_key definition_key, variables: { x: 'abcd' }, businessKey: 'Key'
      expect(Camunda::Poller).to receive(:loop).and_yield
      expect_any_instance_of(Camunda::ExternalTask).to receive(:queue_task).and_return('something')
    end

    it '#fetch_and_execute' do
      Camunda::Poller.fetch_and_execute(%w[CamundaWorkflow])
    end
  end
end
