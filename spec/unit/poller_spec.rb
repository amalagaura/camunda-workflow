require 'camunda/workflow'
require 'camunda/model'
require 'camunda/poller'

RSpec.describe Camunda::Poller do
  class CamundaWorkflow
    module DoSomething
     # def self.perform_later(id,variables)
       # puts "Passed through perform now"
      # end
    end
  end
  let(:poller) { Camunda::Poller.fetch_and_execute(%w[CamundaWorkflow]) }

  context 'start the poller' do
    it '#fetch_and_execute' do
      VCR.use_cassette('poller_fetch_and_execute') do
        expect { expect(poller).to receive(:loop).and_yield }.to raise_error(NoMethodError)
      end
    end
  end
end
