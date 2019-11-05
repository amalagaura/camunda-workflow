require 'rails/generators/testing/behaviour'
require 'generators/camunda/spring_boot/spring_boot_generator.rb'

describe Camunda::Generators::SpringBootGenerator do
  include FileUtils

  let(:dummy_app) { Dummy::Application }
  let(:generator) { Camunda::Generators::SpringBootGenerator }
  let(:dummy_app_root) { File.expand_path('../dummy', __dir__) }

  before do
    generator.start([], destination_root: dummy_app_root)
  end

  let(:spring_app) { File.join(dummy_app_root, ['bpmn']) }
  describe 'installed files' do
    it "Checks if bpmn directory exists" do
      expect(Pathname.new(spring_app)).to be_directory
    end

    it "expects diagrams directory to exist" do
      expect(Pathname.new(spring_app + "/diagrams")).to be_directory
    end

    it "expects java_app directory to exist" do
      expect(Pathname.new(spring_app + "/java_app")).to be_directory
    end

    it "expect java_app src directory exists" do
      expect(Pathname.new(spring_app + "/java_app/src")).to be_directory
    end

    it "expects java_app main directory exists" do
      expect(Pathname.new(spring_app + "/java_app/src/main")).to be_an_directory
    end

    it "expects java_app java directory to exist" do
      expect(Pathname.new(spring_app + "/java_app/src/main/java")).to be_directory
    end

    it "expects java_app camunda file to exist" do
      expect(Pathname.new(spring_app + "/java_app/src/main/java/camunda")).to be_directory
    end

    it "expects java_app Camunda.java file to exist" do
      expect(Pathname.new(spring_app + "/java_app/src/main/java/camunda/Camunda.java")).to be_file
    end

    it "expects if java_app resources directory exists" do
      expect(Pathname.new(spring_app + "/java_app/src/main/resources")).to be_directory
    end

    it "expects if an application.properties file exists" do
      expect(Pathname.new(spring_app + "/java_app/src/main/resources/application.properties")).to be_file
    end
    it "expects pom.xml file to exist" do
      expect(Pathname.new(spring_app + "/java_app/pom.xml")).to be_file
    end
  end

  after do
    remove_dir File.expand_path('../dummy/bpmn', __dir__)
  end
end
