require 'rails/generators/testing/behaviour'
require 'generators/camunda/install/install_generator.rb'

describe Camunda::Generators::InstallGenerator do
  include FileUtils

  let(:dummy_app_root) { File.expand_path('../dummy', __dir__) }
  let(:camunda_job) { File.join(dummy_app_root, 'app', 'jobs', 'camunda_job.rb') }

  describe 'runs install_generator with success' do
    before { described_class.start([], destination_root: dummy_app_root) }

    after { remove_file File.expand_path(camunda_job) }

    it('creates camunda_job.rb') { expect(Pathname.new(camunda_job)).to be_file }
  end
end
