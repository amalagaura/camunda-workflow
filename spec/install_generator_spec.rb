require 'rails/generators/testing/behaviour'
require 'generators/camunda/install/install_generator.rb'


describe Camunda::Generators::InstallGenerator do
  include FileUtils

  let (:generator) { Camunda::Generators::InstallGenerator }
  let(:dummy_app_root) { File.expand_path('../spec/dummy', __dir__) }


  before do
    generator.start([], destination_root: dummy_app_root)
  end

  it 'has camunda_job.rb' do
  end

end
