RSpec.describe Camunda::ProcessDefinition, :vcr, :deployment do
  context '#start_by_key' do
    let(:subject) do
      Camunda::ProcessDefinition.start_by_key 'CamundaWorkflow',
                                              businessKey: 'WorkflowBusinessKey',
                                              variables: { s: 'abcd', n: 1, f: 2.3, f1: 2.0, h: { x: 1 }, a: [1, 2], b: true }
    end
    it "succeeded" do
      is_expected.to be_an_instance_of(Camunda::ProcessInstance)
      expect(subject.business_key).to eq("WorkflowBusinessKey")
      expect(subject.variables).to eq(a: "ARRAY", b: true, f: 2.3, f1: 2.0, h: "OBJECT", n: 1, s: "abcd")
    end
  end
  context 'cannot start' do
    let(:subject) { Camunda::ProcessDefinition.new(id: 'unknown') }
    it('does not create') { expect { subject.start }.to raise_error(Camunda::ProcessEngineException) }
  end
end
