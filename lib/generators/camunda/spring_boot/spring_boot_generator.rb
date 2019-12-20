module Camunda
  module Generators
    # Creates a skeleton Java Spring Boot app, which also contains the minimal files to run unit tests on a BPMN file.
    # This can be used to start a Camunda instance with a REST api. This can also be deployed to PCF by generating a
    # Spring Boot jar and pushing it.
    class SpringBootGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      class_option :bpmn_folder_name, type: :string, default: 'bpmn'
      class_option :java_app_folder_name, type: :string, default: 'java_app'
      class_option :resources_folder_name, type: :string, default: 'resources'

      # Links resources to the java app resources folder
      def link_resources_folder
        create_link resources_path, File.join(java_app_folder_name, 'src/main/resources/')
      end

      # Copies all spring boot files into a rails application and provides a Camunda engine for testing.
      def copy_java_app_files
        copy_file 'pom.xml', File.join(java_app_path, 'pom.xml')
        copy_file 'camunda.cfg.xml', File.join(java_app_path, 'src/test/resources/camunda.cfg.xml')
        copy_file 'logback.xml', File.join(java_app_path, 'src/main/resources/logback.xml')
        copy_file 'application.properties', File.join(java_app_path, 'src/main/resources/application.properties')
        copy_file 'Camunda.java', File.join(java_app_path, 'src/main/java/camunda/Camunda.java')
        copy_file 'camunda.rake', 'lib/tasks/camunda.rake'
      end

      # Copies a sample bpmn file to help demonstrate the usage for camunda-workflow
      def copy_sample_bpmn
        copy_file 'sample.bpmn', File.join(resources_path, 'sample.bpmn')
        copy_file 'ProcessScenarioTest.java', File.join(java_app_path, 'src/test/java/unittest/ProcessScenarioTest.java')
      end

      # Add spring boot files to .gitignore
      def add_to_ignores
        ignores = %w[.gitignore]
        ignores << '.cfignore' if File.exist?('.cfignore')
        ignores.each do |file|
          append_to_file file do
            "\n# BPMN Java app\n" +
              File.join(java_app_path, 'target') +
              "\n"
          end
        end
      end

      # Provides instruction regarding an error with EventedFileChecker listening on the entire Rails folder.
      def output_error_instructions
        puts <<~DOC
          If you get an error when starting your Rails app

          ** ERROR: directory is already being watched! **

          Directory: bpmn/java_app/src/main/resources
          is already being watched through: bpmn/diagrams

          MORE INFO: https://github.com/guard/listen/wiki/Duplicate-directory-errors

          It is because ActionMailer preview causes test/mailers/previews to get added to the Rails EventedFileChecker
          by default. RSpec is supposed to override it, but it is not overridden properly for EventedFileChecker and/or
          you don't have spec/mailers/preview existing. If that directory does not exist it goes to the first common
          directory that exists which is your Rails root folder.

          So EventedFileChecker is listening to your entire Rails folder. Not a big problem, but it causes a problem
          for our created symlink.

          So add:

             config.action_mailer.show_previews = false

          to your development.rb file to solve Listen errors about a symlink. Unless you are using ActionMailer
          previews in which case you should have the directory created already.
        DOC
      end

      private

      def bpmn_folder_name
        options['bpmn_folder_name']
      end

      def java_app_folder_name
        options['java_app_folder_name']
      end

      def resources_folder_name
        options['resources_folder_name']
      end

      def resources_path
        File.join(bpmn_folder_name, resources_folder_name)
      end

      def java_app_path
        File.join(bpmn_folder_name, java_app_folder_name)
      end
    end
  end
end
