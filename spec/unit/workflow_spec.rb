require 'camunda/workflow'

RSpec.describe Camunda::Workflow do
  let(:workflow) { Camunda::Workflow }
  before do
    Camunda::Workflow
  end
  context 'test initialize default variable' do
    it 'should have an engine_url' do
      expect(workflow.configuration.engine_url).to eq('http://localhost:8080')
    end

    it 'should have an engine_route_prefix of rest-engine' do
      allow(Camunda::Workflow::Configuration).to receive(:new).and_return("rest-engine")
      expect(workflow.configuration.engine_route_prefix).to eq("rest-engine")
    end

    it 'should have a default lock duration of 14 days' do
      expect(workflow.configuration.lock_duration).to eq(14.days)
    end

    it 'should have a default polling duration of 30 seconds' do
      expect(workflow.configuration.long_polling_duration).to eq(30.seconds)
    end

    it 'should be able to pass a new engine_url' do
      workflow.configure do |config|
        config.engine_url = 'test.com'
      end
      p workflow.configuration.engine_url
    end
  end
end