require 'rails/generators/testing/behaviour'
require 'generators/camunda/spring_boot/spring_boot_generator.rb'

describe Camunda::Generators::SpringBootGenerator do
  include FileUtils
  let(:dummy_app_dir) { File.expand_path('../dummy', __dir__) }
  let(:spring_app) { File.join(dummy_app_dir, ['bpmn']) }

  describe "run generator" do
    before { described_class.start([], destination_root: dummy_app_dir) }

    after { remove_dir File.expand_path('../dummy/bpmn', __dir__) }

    # rubocop:disable RSpec/ExampleLength
    it("checks if files and directories exist") do
      expect(Pathname.new(spring_app + "/diagrams")).to be_directory
      expect(Pathname.new(spring_app + "/java_app/src/main/java/camunda/Camunda.java")).to be_file
      expect(Pathname.new(spring_app + "/java_app/src/main/resources/application.properties")).to be_file
      expect(Pathname.new(spring_app + "/java_app/pom.xml")).to be_file
      expect(Pathname.new(spring_app + "/java_app/src/main/resources/sample.bpmn")).to be_file
      expect(Pathname.new(spring_app + "/java_app/src/main/resources/logback.xml")).to be_file
    end
    # rubocop:enable RSpec/ExampleLength
  end

  it("expects to show output error") {
    expect { described_class.new.output_error_instructions }
      .to output(/If you get an error when starting your Rails app/).to_stdout
  }
end
