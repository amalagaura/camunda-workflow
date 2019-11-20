require 'nokogiri'

RSpec.describe Camunda::BpmnXML do
  let(:bpmn) { Camunda::BpmnXML.new(File.open("#{__dir__}/../bpmn_test_files/sample.bpmn")) }

  context 'scans file and creates class' do
    it 'topics to be an array' do
      string = bpmn.topics
      expect(string).to eq %w[CamundaWorkflow]
    end

    it 'expects module_name to be string' do
      expect(bpmn.to_s).to eq('CamundaWorkflow')
    end
  end
end
