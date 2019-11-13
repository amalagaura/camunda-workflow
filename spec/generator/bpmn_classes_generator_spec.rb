require 'spec_helper'
require 'rails/generators/testing/behaviour'
require 'generators/camunda/bpmn_classes/bpmn_classes_generator.rb'
require 'camunda/bpmn_xml'

describe Camunda::Generators::BpmnClassesGenerator do
  include FileUtils

  let(:generator) { Camunda::Generators::BpmnClassesGenerator }
  let(:dummy_app_root) { File.expand_path('../dummy', __dir__) }

  let(:model) { Camunda::Deployment.create file_name: 'spec/bpmn_test_files/sample.bpmn' }

  before do
    #generator.start([File.expand_path("lib/generators/camunda/spring_boot/templates/sample_test.bpmn")], destination_root: dummy_app_root)
    generator.start([File.expand_path("spec/bpmn_test_files/sample_test.bpmn")], destination_root: dummy_app_root)
    generator.start([File.expand_path("spec/bpmn_test_files/sample_fail.bpmn")], destination_root: dummy_app_root)
  end

  it 'creates files' do

  end

  after do
    remove_dir File.expand_path("../dummy/app/bpmn", __dir__)
  end
end
