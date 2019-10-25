require 'rails/generators/testing/behaviour'
require 'generators/camunda/bpmn_classes/bpmn_classes_generator.rb'

describe Camunda::Generators::BpmnClassesGenerator do
  include FileUtils

  let(:generator) { Camunda::Generators::BpmnClassesGenerator }
  let(:dummy_app_root) { File.expand_path('../dummy', __dir__) }

  before do
    puts "running generator"
    generator.start([], destination_root: dummy_app_root)
  end


end
