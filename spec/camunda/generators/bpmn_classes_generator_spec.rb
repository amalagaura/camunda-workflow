require 'nokogiri'
require 'rails/generators/testing/behaviour'
require 'generators/camunda/bpmn_classes/bpmn_classes_generator.rb'

describe Camunda::Generators::BpmnClassesGenerator do
  include FileUtils

  let(:dummy_app_root) { File.expand_path('../dummy', __dir__) }

  describe 'runs sample with success' do
    before { described_class.start([File.expand_path("spec/bpmn_test_files/sample.bpmn")], destination_root: dummy_app_root) }

    after { remove_dir File.expand_path("../dummy/app/bpmn", __dir__) }

    it("has the module") { expect(File).to exist(File.join(dummy_app_root, "app/bpmn/camunda_workflow.rb")) }
    it("has the class") { expect(File).to exist(File.join(dummy_app_root, "app/bpmn/camunda_workflow/do_something.rb")) }
  end

  it 'runs sample sample with failure' do
    described_class.start([File.expand_path("spec/bpmn_test_files/sample_fail.bpmn")], destination_root: dummy_app_root)
  end
end
