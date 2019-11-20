require 'faraday_middleware'

RSpec.describe Camunda::Deployment do
  let(:subject) { Camunda::Deployment.create file_name: 'lib/generators/camunda/spring_boot/templates/sample.bpmn' }

  it '#creates a running instance', :vcr do
    expect(subject[:response].status).to eq(200)
  end

  it 'tries to create model without a file path' do
    expect { Camunda::Deployment.create }.to raise_error(ArgumentError)
  end
end
