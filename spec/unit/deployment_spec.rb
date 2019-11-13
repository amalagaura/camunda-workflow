require 'rails'
require 'faraday_middleware'
require 'camunda'
require 'camunda/workflow.rb'
require 'camunda/model.rb'
require 'camunda/deployment.rb'

RSpec.describe Camunda::Deployment do
  before do
    Camunda::Workflow.configure do |config|
      config.engine_url = 'http://localhost:8080'
      config.engine_route_prefix = 'rest'
    end
  end
  let(:model) { Camunda::Deployment.create file_name: 'lib/generators/camunda/spring_boot/templates/sample.bpmn' }

  it '#creates a running instance' do
    VCR.use_cassette('deployment_results') do
      expect(model[:response].status).to eq(200)
    end
  end

  it 'trys to create model without a file path' do
    expect { Camunda::Deployment.create }.to raise_error(ArgumentError)
  end
end
