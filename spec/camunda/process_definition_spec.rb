RSpec.describe Camunda::ProcessDefinition, :deployment, :vcr do
  describe '#start_by_key' do
    let(:instance) do
      described_class.start_by_key definition_key,
                                   businessKey: 'WorkflowBusinessKey',
                                   variables: { s: 'abcd', n: 1, f: 2.3, f1: 2.0, h: { x: 1 }, a: [1, 2], b: true }
    end

    it "succeeded" do
      expect(instance).to be_an_instance_of(Camunda::ProcessInstance)
      expect(instance.business_key).to eq("WorkflowBusinessKey")
      expect(instance.variables).to eq({ a: "ARRAY", b: true, f: 2.3, f1: 2.0, h: "OBJECT", n: 1, s: "abcd" }.stringify_keys)
    end
  end

  describe 'cannot start' do
    let(:instance) { described_class.new(id: 'unknown') }

    it('does not create') { expect { instance.start }.to raise_error(Camunda::ProcessEngineException) }
  end
end
