require 'camunda/workflow'
require 'camunda/model'
require 'camunda/poller'

RSpec.describe Camunda::Poller do
  class CamundaWorkflow
    module DoSomething
      # Method has been commented out to prevent the loop from continuing.
       #def self.perform_later(id,variables)
         #puts "Passed through perform now"
       #end
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

  it '#fetch and execute with no class' do
    #klass = Camunda::Poller.fetch_and_execute (%w[test])
    #p klass
  end
end
