RSpec.describe "#Camunda::Signal" do
  let(:signal) { Camunda::Signal.send_signal({ name: "baz", variables: { foo: "bar" } }) }
  it 'sends signal' do
    VCR.use_cassette('signal_request') do
      expect(signal[:variables]).to eq({"foo" => {"value"=>"bar", "type"=>"String"}})
      expect(signal[:name]).to eq("baz")
    end
  end

end