RSpec.describe "#Camunda::Signal" do
  let(:signal) { Camunda::Signal.send_signal(name: "baz", variables: { foo: "bar" }) }
  it 'sends signal', :vcr do
    expect(signal[:variables]).to eq("foo" => { "value" => "bar", "type" => "String" })
    expect(signal[:name]).to eq("baz")
  end
end
