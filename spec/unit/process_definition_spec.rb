RSpec.describe Camunda::ProcessDefinition do
  it 'starts a process' do
    VCR.use_cassette('process_definition') do
      definition = Camunda::ProcessDefinition.start id: 'CamundaWorkflow'
      expect(definition).to be_a(Camunda::ProcessDefinition)
    end
  end

  it 'starts a process with variables' do
    VCR.use_cassette('process_definition_with_variables') do
      Camunda::ProcessDefinition.start id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
    end
  end
end
