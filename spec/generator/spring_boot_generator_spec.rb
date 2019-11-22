require 'rails/generators/testing/behaviour'
require 'generators/camunda/spring_boot/spring_boot_generator.rb'

# rubocop:disable Metrics/LineLength
describe Camunda::Generators::SpringBootGenerator do
  include FileUtils

  let(:spring_app) { File.join(File.expand_path('../dummy', __dir__), ['bpmn']) }
  before(:all) { Camunda::Generators::SpringBootGenerator.start([], destination_root: File.expand_path('../dummy', __dir__)) }
  it("checks if bpmn directory exists") { expect(Pathname.new(spring_app)).to be_directory }
  it("expects diagrams directory to exist") { expect(Pathname.new(spring_app + "/diagrams")).to be_directory }
  it("expects java_app directory to exist") { expect(Pathname.new(spring_app + "/java_app")).to be_directory }
  it("expect java_app src directory exists") { expect(Pathname.new(spring_app + "/java_app/src")).to be_directory }
  it("expects java_app main directory exists") { expect(Pathname.new(spring_app + "/java_app/src/main")).to be_directory }
  it("expects java_app java directory to exist") { expect(Pathname.new(spring_app + "/java_app/src/main/java")).to be_directory }
  it("expects java_app camunda file to exist") { expect(Pathname.new(spring_app + "/java_app/src/main/java/camunda")).to be_directory }
  it("expects java_app Camunda.java file to exist") { expect(Pathname.new(spring_app + "/java_app/src/main/java/camunda/Camunda.java")).to be_file }
  it("expects if java_app resources directory exists") { expect(Pathname.new(spring_app + "/java_app/src/main/resources")).to be_directory }
  it("expects if an application.properties file exists") { expect(Pathname.new(spring_app + "/java_app/src/main/resources/application.properties")).to be_file }
  it("expects pom.xml file to exist") { expect(Pathname.new(spring_app + "/java_app/pom.xml")).to be_file }
  it("expects to show output error") { expect { Camunda::Generators::SpringBootGenerator.new.output_error_instructions }.to output(/If you get an error when starting your Rails app/).to_stdout }
  after(:all) { remove_dir File.expand_path('../dummy/bpmn', __dir__) }
end
# rubocop:enable Metrics/LineLength
