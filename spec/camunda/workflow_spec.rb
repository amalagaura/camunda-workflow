RSpec.describe Camunda::Workflow do
  let(:configuration) { described_class.configuration }

  before { described_class.configure { |config| config.worker_id = 'worker' } }

  describe '#configuration defaults' do
    it('default engine_url') { expect(configuration.engine_url).to eq('http://localhost:8080') }
    it('default engine_route_prefix of rest-engine') { expect(configuration.engine_route_prefix).to eq("rest") }
    it('default lock duration of 14 days') { expect(configuration.lock_duration).to eq(14.days) }
    it('default polling duration of 30 seconds') { expect(configuration.long_polling_duration).to eq(30.seconds) }
    it('changed worker_id') { expect(configuration.worker_id).to eq('worker') }
  end
end
