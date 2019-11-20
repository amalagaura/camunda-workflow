RSpec.describe '#Caumnda' do
  context 'test Camunda methods' do
    it 'expects #logger' do
      expect(Camunda.logger).to be_truthy
    end
  end
end
