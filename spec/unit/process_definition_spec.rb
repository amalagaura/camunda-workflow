require 'camunda/workflow'
require 'camunda/model'
require 'camunda/process_definition'

RSpec.describe Camunda::ProcessDefinition do
  it 'starts a process' do
    VCR.use_cassette('process_definition') do
      definition = Camunda::ProcessDefinition.start id: 'CamundaWorkflow'
      # expect(definition[:response].status).to eq(200)
    end
  end

  it 'starts a process with variables' do
    VCR.use_cassette('process_definition_with_variables') do
      # rubocop:disable Metrics/LineLength
      start_response = Camunda::ProcessDefinition.start_with_variables id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
      # rubocop:enable Metrics/LineLength
      p start_response
    end
  end
end
