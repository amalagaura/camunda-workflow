RSpec.describe Camunda::VariableSerialization do
  let(:helper) { Class.new { include Camunda::VariableSerialization } }
  let(:hash) do
    { business_workflow: "test", boolean_type: true, integer_type: 13, hash_string: { foo: "bar" },
      array_string: %w[a b], array_hash: [{ foo: "bar", bar: %w[foo] }], test_double: 0.03451 }
  end
  let(:subject) { helper.serialize_variables(hash) }
  context '#serialize_variables' do
    it('type string') { expect(subject["businessWorkflow"]["type"]).to eq("String") }
    it('type string') { expect(subject["businessWorkflow"]["value"]).to eq("test") }
    it('type Boolean ') { expect(subject["booleanType"]["type"]).to eq("Boolean") }
    it('type Boolean ') { expect(subject["booleanType"]["value"]).to eq(true) }
    it('type Integer') { expect(subject["integerType"]["type"]).to eq("Integer") }
    it('type Integer') { expect(subject["integerType"]["value"]).to eq(13) }
    it('type Json') { expect(subject["hashString"]["type"]).to eq("Json") }
    it('type Json') { expect(subject["hashString"]["value"]).to eq('{"foo":"bar"}') }
    it('type Array') { expect(subject["arrayString"]["type"]).to eq("Json") }
    it('type Array') { expect(subject["arrayString"]["value"]).to eq('["a","b"]') }
    it('type Array') { expect(subject["arrayHash"]["type"]).to eq("Json") }
    it('type Array') { expect(subject["arrayHash"]["value"]).to eq('[{"foo":"bar","bar":["foo"]}]') }
    it('type Double') { expect(subject["testDouble"]["type"]).to eq("Double") }
    it('type Double') { expect(subject["testDouble"]["value"]).to eq(0.03451) }
  end

  context 'unknown type' do
    let(:hash) { { hello: Class.new } }
    it { expect { subject }.to raise_error(ArgumentError) }
  end
end
