RSpec.describe Camunda::Poller do
  module CamundaWorkflow
    class DoSomething
    end
  end

  context 'start the poller' do
    before do
      Camunda::ProcessDefinition.start id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'Key'
      expect(Camunda::Poller).to receive(:loop).and_yield
      expect_any_instance_of(Camunda::ExternalTask).to receive(:queue_task).and_return('something')
    end

    it '#fetch_and_execute', :vcr do
      Camunda::Poller.fetch_and_execute(%w[CamundaWorkflow])
    end
  end
end
