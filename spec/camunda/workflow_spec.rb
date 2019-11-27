RSpec.describe Camunda::Workflow do
  describe '#configuration' do
    let(:configuration) { described_class.configuration }

    it('default engine_url') { expect(configuration.engine_url).to eq('http://localhost:8080') }
    # This is overridden in the spec_helper.rb
    it('default engine_route_prefix of rest-engine') { expect(configuration.engine_route_prefix).to eq("rest") }
    it('default lock duration of 14 days') { expect(configuration.lock_duration).to eq(14.days) }
    it('default polling duration of 30 seconds') { expect(configuration.long_polling_duration).to eq(30.seconds) }
  end
end
