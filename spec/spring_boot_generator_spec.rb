require 'rails/generators/testing/behaviour'
require 'generators/camunda/spring_boot/spring_boot_generator.rb'


describe Camunda::Generators::SpringBootGenerator do
  include FileUtils

  let(:dummy_app) { Dummy::Application }
  let (:generator) { Camunda::Generators::SpringBootGenerator }
  let(:dummy_app_root) { File.expand_path('../spec/dummy', __dir__) }


  before do
    generator.start([], destination_root: dummy_app_root)
  end

  it "start a new spring boot" do
    thread = Thread.new do
      system("mvn spring-boot:run", chdir: File.expand_path('../spec/dummy/bpmn/java_app', __dir__))
    end

  end

  after do

   remove_dir File.expand_path('../spec/dummy/bpmn', __dir__)
 end

  it 'has camunda_job.rb' do
  end

end
