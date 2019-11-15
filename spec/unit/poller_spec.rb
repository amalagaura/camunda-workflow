RSpec.describe Camunda::Poller do
  module CamundaWorkflow
    class DoSomething
    end
  end

  context 'start the poller' do
    before do
      expect(Camunda::Poller).to receive(:loop).and_yield
      expect_any_instance_of(Camunda::ExternalTask).to receive(:queue_task).and_return('something')
    end

    it '#fetch_and_execute' do
      VCR.use_cassette('poller_fetch_and_execute') do
        Camunda::Poller.fetch_and_execute(%w[CamundaWorkflow])
      end
    end
  end
end
