require 'camunda/workflow'
require 'camunda/model'
require 'camunda/poller'

RSpec.describe Camunda::Poller do
  let(:poller) { class_double(Camunda::Poller) }

  context 'start the poller' do
    it '#fetch_and_execute' do
      allow(poller).to receive(:fetch_and_execute).and_return("Starts the poller")
    end
  end
end
