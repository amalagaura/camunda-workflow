module Camunda
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      def copy_camunda_application_job
        copy_file 'camunda_job.rb', 'app/jobs/camunda_job.rb'
      end
    end
  end
end
