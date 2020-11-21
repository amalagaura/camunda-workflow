require 'rails/generators/testing/behaviour'
require 'generators/camunda/spring_boot/spring_boot_generator'

describe Camunda::Generators::SpringBootGenerator do
  include FileUtils
  let(:dummy_app_dir) { Pathname.new(File.expand_path('../dummy', __dir__)) }
  let(:bpmn_folder) { dummy_app_dir.join('bpmn') }
  let(:spring_app) { bpmn_folder.join('java_app') }

  describe "run generator" do
    before { remove_dir(dummy_app_dir) if Dir.exist?(dummy_app_dir) }

    after { remove_dir dummy_app_dir }

    it("checks if files and directories exist") do
      described_class.start([], destination_root: dummy_app_dir)

      expect(spring_app.join("pom.xml")).to be_file
      expect(bpmn_folder.join("resources/sample.bpmn")).to be_file
      expect(spring_app.join("src/main/java/camunda/Camunda.java")).to be_file
      expect(spring_app.join("src/main/resources/application.properties")).to be_file
      expect(spring_app.join("src/main/resources/sample.bpmn")).to be_file
      expect(spring_app.join("src/main/resources/logback.xml")).to be_file
    end
  end
end
