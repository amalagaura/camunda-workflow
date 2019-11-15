RSpec.describe '#Caumnda' do
  context 'test Camunda methods' do
    it 'expects #logger' do
      expect(Camunda.logger).to be_truthy
    end

    it 'standard error class' do
      expect(Camunda::MissingImplementationClass.new("some_class")).to be_truthy
    end
  end
end
