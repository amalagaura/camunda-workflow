require 'rails/generators/testing/behaviour'
require 'generators/camunda/spring_boot/spring_boot_generator.rb'

describe Camunda::Generators::SpringBootGenerator do
  include FileUtils

  let(:dummy_app) { Dummy::Application }
  let(:generator) { Camunda::Generators::SpringBootGenerator }
  let(:dummy_app_root) { File.expand_path('../dummy', __dir__) }
  let(:spring_app) { File.join(dummy_app_root, ['bpmn']) }
  # rubocop:disable Metrics/LineLength
  context 'runs spring_boot_generator_spec' do
    before { generator.start([], destination_root: dummy_app_root) }
    it("checks if bpmn directory exists") { expect(Pathname.new(spring_app)).to be_directory }
    it("expects diagrams directory to exist") { expect(Pathname.new(spring_app + "/diagrams")).to be_directory }
    it("expects java_app directory to exist") { expect(Pathname.new(spring_app + "/java_app")).to be_directory }
    it("expect java_app src directory exists") { expect(Pathname.new(spring_app + "/java_app/src")).to be_directory }
    it("expects java_app main directory exists") { expect(Pathname.new(spring_app + "/java_app/src/main")).to be_an_directory }
    it("expects java_app java directory to exist") { expect(Pathname.new(spring_app + "/java_app/src/main/java")).to be_directory }
    it("expects java_app camunda file to exist") { expect(Pathname.new(spring_app + "/java_app/src/main/java/camunda")).to be_directory }
    it("expects java_app Camunda.java file to exist") { expect(Pathname.new(spring_app + "/java_app/src/main/java/camunda/Camunda.java")).to be_file }
    it("expects if java_app resources directory exists") { expect(Pathname.new(spring_app + "/java_app/src/main/resources")).to be_directory }
    it("expects if an application.properties file exists") { expect(Pathname.new(spring_app + "/java_app/src/main/resources/application.properties")).to be_file }
    it("expects pom.xml file to exist") { expect(Pathname.new(spring_app + "/java_app/pom.xml")).to be_file }
    it("expects to show output error") { expect { generator.new.output_error_instructions }.to output(/If you get an error when starting your Rails app/).to_stdout }
    after { remove_dir File.expand_path('../dummy/bpmn', __dir__) }
  end
  # rubocop:enable Metrics/LineLength
end
