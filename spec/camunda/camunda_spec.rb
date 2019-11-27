RSpec.describe Camunda do
  it('expects #logger') { expect(described_class.logger).to an_instance_of(Logger) }
end
