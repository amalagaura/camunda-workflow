require 'nokogiri'

RSpec.describe Camunda::BpmnXML do
  let(:bpmn) { described_class.new(File.open("#{__dir__}/../bpmn_test_files/sample.bpmn")) }

  describe 'scans file and creates class' do
    it('topics to be an array') { expect(bpmn.topics).to eq %w[CamundaWorkflow] }
    it('expects module_name to be string') { expect(bpmn.to_s).to eq(definition_key) }
  end
end
