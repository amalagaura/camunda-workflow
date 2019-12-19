RSpec.describe Camunda::Deployment, :vcr do
  describe "creates process definition" do
    let(:definition) { described_class.create(file_names: ['spec/bpmn_test_files/sample.bpmn']).first }

    it('creates a process definition that can be started') do
      expect(definition).to be_an_instance_of(Camunda::ProcessDefinition)
      expect(definition.start).to be_an_instance_of(Camunda::ProcessInstance)
    end
  end

  it 'throws an error with invalid bpmn' do
    expect { described_class.create file_names: ['Gemfile'] }.to raise_error(Camunda::ProcessEngineException)
  end

  it 'throws a Camunda::Model::RecordNotFound' do
    expect { described_class.find_by!(id: 'doesnt-exist') }.to raise_error(Camunda::Model::RecordNotFound)
  end
end
