module Camunda
  module Generators
    # Creates `app/jobs/camunda_job.rb`. A class which inherits from ApplicationJob and includes `ExternalTaskJob`.
    # It can be changed to include Sidekiq::Worker instead.
    # All of the BPMN worker classes will inherit from this class
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      # Copies the camunda_job file to the Rails application.
      def copy_camunda_application_job
        copy_file 'camunda_job.rb', 'app/jobs/camunda_job.rb'
      end
    end
  end
end
