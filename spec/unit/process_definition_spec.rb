RSpec.describe Camunda::ProcessDefinition do
  context '#PrecessDefinition class', :vcr do
    it 'starts a process' do
      definition = Camunda::ProcessDefinition.start id: 'CamundaWorkflow'
      expect(definition).to be_a(Camunda::ProcessDefinition)
    end
    it 'starts a process with variables' do
      Camunda::ProcessDefinition.start id: 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
    end
  end
end
