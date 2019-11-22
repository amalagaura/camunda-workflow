RSpec.describe '#Caumnda' do
  it('expects #logger') { expect(Camunda.logger).to an_instance_of(Logger) }
end
