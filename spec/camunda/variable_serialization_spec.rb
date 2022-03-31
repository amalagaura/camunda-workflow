RSpec.describe Camunda::VariableSerialization do
  let(:helper) { Class.new { include Camunda::VariableSerialization } }
  let(:hash) do
    { business_workflow: "test", boolean_type: true, integer_type: 13, hash_string: { foo: "bar" },
      array_string: %w[a b], array_hash: [{ foo: "bar", bar: %w[foo] }], test_double: 0.03451, object: Object.new }
  end
  let(:serialized) { helper.serialize_variables(hash) }

  describe '#serialize_variables' do
    it('type string') { expect(serialized["businessWorkflow"]["type"]).to eq("String") }
    it('value string') { expect(serialized["businessWorkflow"]["value"]).to eq("test") }
    it('type Boolean ') { expect(serialized["booleanType"]["type"]).to eq("Boolean") }
    it('value Boolean ') { expect(serialized["booleanType"]["value"]).to eq(true) }
    it('type Integer') { expect(serialized["integerType"]["type"]).to eq("Integer") }
    it('value Integer') { expect(serialized["integerType"]["value"]).to eq(13) }
    it('type Json') { expect(serialized["hashString"]["type"]).to eq("Json") }
    it('value Json') { expect(serialized["hashString"]["value"]).to eq('{"foo":"bar"}') }
    it('type Array') { expect(serialized["arrayString"]["type"]).to eq("Json") }
    it('value Array') { expect(serialized["arrayString"]["value"]).to eq('["a","b"]') }
    it('type Array Hash') { expect(serialized["arrayHash"]["type"]).to eq("Json") }
    it('value Array Hash') { expect(serialized["arrayHash"]["value"]).to eq('[{"foo":"bar","bar":["foo"]}]') }
    it('type Double') { expect(serialized["testDouble"]["type"]).to eq("Double") }
    it('value Double') { expect(serialized["testDouble"]["value"]).to eq(0.03451) }
    it('object string') { expect(serialized["object"]["value"]).to start_with("#<Object:") }
  end
end
