RSpec.describe Camunda::Signal, :vcr do
  # We are just testing that we can send a signal with variables and we get a 204 which means Camunda received it
  let(:response) { described_class.create name: "baz", variables: { foo: "bar" } }

  it('call succeeded') { expect(response.errors).to be_empty }
end
