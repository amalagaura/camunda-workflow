RSpec.describe Camunda::VariableSerialization do
  let(:helper) { Class.new { include Camunda::VariableSerialization } }
  context 'is expected_to transform snake_case to camelCase' do
    it '#camelcase_keys' do
      hash = { camel_case: "test" }
      expect(helper.camelcase_keys(hash)).to eq("camelCase" => "test")
    end
  end
  context 'is expected_to transform hash snake_case to camelCase and assign type' do
    it '#serialize variable as type string' do
      hash = { business_workflow: "test" }
      result = helper.serialize_variables(hash)
      expect(result["businessWorkflow"]["type"]).to eq("String")
    end
    it '#serialze variable as type Boolean ' do
      hash = { boolean_type: true }
      result = helper.serialize_variables(hash)
      expect(result["booleanType"]["type"]).to eq("Boolean")
    end

    it '#serialize variable as type Integer' do
      hash = { integer_type: 13 }
      result = helper.serialize_variables(hash)
      expect(result["integerType"]["type"]).to eq("Integer")
    end

    it '#serialize variable as type Json' do
      hash = { hash_string: { foo: "bar" } }
      result = helper.serialize_variables(hash)
      expect(result["hashString"]["type"]).to eq("Json")
    end

    it '#serialize variable as type Double' do
      variable = { test_double: 0.03451 }
      result = helper.serialize_variables(variable)
      expect(result["testDouble"]["type"]).to eq("Double")
    end

    it '#serialize variable as unknown' do
      variable = { hello: Class.new }
      expect { helper.serialize_variables(variable) }.to raise_error("Not supporting complex types yet")
    end
  end
  context '#transform_json' do
    it 'is expected to transform Array to Json' do
      array = [hello: "test", foo: "bar"]
      result = helper.transform_json(array)
      expect(result).to eq([{ "foo" => "bar", "hello" => "test" }])
    end
    it 'is expected to return json if json' do
      json = { "foo" => "bar" }.to_json
      result = helper.transform_json(json)
      expect(result).to eq("{\"foo\":\"bar\"}")
    end
  end
end
