require 'rails/generators/testing/behaviour'
require 'generators/camunda/install/install_generator.rb'

describe Camunda::Generators::InstallGenerator do
  include FileUtils

  let(:generator) { Camunda::Generators::InstallGenerator }
  let(:dummy_app_root) { File.expand_path('../dummy', __dir__) }
  let(:camunda_job) { File.join(dummy_app_root, 'app', 'jobs', 'camunda_job.rb') }

  context 'runs install_generator with success' do
    before { generator.start([], destination_root: dummy_app_root) }
    it('creates camunda_job.rb') { expect(Pathname.new(camunda_job)).to be_file }
    after { remove_file File.expand_path(camunda_job) }
  end
end
