RSpec.describe Camunda::Workflow do
  context '#configuration' do
    let(:subject) { Camunda::Workflow.configuration }
    it('default engine_url') { expect(subject.engine_url).to eq('http://localhost:8080') }
    # This is overridden in the spec_helper.rb
    it('default engine_route_prefix of rest-engine') { expect(subject.engine_route_prefix).to eq("rest") }
    it('default lock duration of 14 days') { expect(subject.lock_duration).to eq(14.days) }
    it('default polling duration of 30 seconds') { expect(subject.long_polling_duration).to eq(30.seconds) }
  end
end
