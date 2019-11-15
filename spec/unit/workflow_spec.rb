RSpec.describe Camunda::Workflow do
  let(:subject) { Camunda::Workflow }
  context 'test defaults' do
    it('should have an engine_url') { expect(subject.configuration.engine_url).to eq('http://localhost:8080') }
    # This is overridden in the spec_helper.rb
    it('should have an engine_route_prefix of rest-engine') { expect(subject.configuration.engine_route_prefix).to eq("rest") }
    it('should have a default lock duration of 14 days') { expect(subject.configuration.lock_duration).to eq(14.days) }
    it('should have a default polling duration of 30 seconds') do
      expect(subject.configuration.long_polling_duration).to eq(30.seconds)
    end
  end
end
