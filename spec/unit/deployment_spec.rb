RSpec.describe Camunda::Deployment, :vcr do
  context "creates process definition" do
    let(:subject) { Camunda::Deployment.create(file_names: ['spec/bpmn_test_files/sample.bpmn']).first }

    it('creates a process definition that can be started') do
      is_expected.to be_an_instance_of(Camunda::ProcessDefinition)
      expect(subject.start).to be_an_instance_of(Camunda::ProcessInstance)
    end
  end

  it 'throws an error with invalid bpmn' do
    expect { Camunda::Deployment.create file_names: ['README.md'] }.to raise_error(Camunda::ProcessEngineException)
  end
end
