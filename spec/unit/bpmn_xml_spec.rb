require 'camunda/bpmn_xml'

RSpec.describe Camunda::BpmnXML do
  let(:bpmn) { Camunda::BpmnXML.new(File.expand_path("spec/bpmn_test_files/sample.pmn")) }

  context 'scans file and creates class' do
    it 'topics to be an array' do
      string = bpmn.topics
      expect(string).to be_an_instance_of(Array)
    end

    it 'expects module_name to be string' do
      # bpmn.to_s
    end
  end
end
