require 'rails/generators/testing/behaviour'
require 'generators/camunda/install/install_generator.rb'

describe Camunda::Generators::InstallGenerator do
  include FileUtils

  let(:generator) { Camunda::Generators::InstallGenerator }
  let(:dummy_app_root) { File.expand_path('../dummy', __dir__) }

  before do
    generator.start([], destination_root: dummy_app_root)
  end

  let(:camunda_job) { File.join(dummy_app_root, 'app', 'jobs', 'camunda_job.rb') }

  describe 'installed files' do
    it 'creates camunda_job.rb' do
      expect(Pathname.new(camunda_job)).to be_file
    end
  end
end
