module Camunda
  module Generators
    class SpringBootGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      class_option :app_path, type: :string, default: 'bpmn/java_app'
      class_option :diagram_path, type: :string, default: 'bpmn/diagrams'

      def copy_java_app_files
        copy_file 'pom.xml', File.join(bpmn_app_path, 'pom.xml')
        copy_file 'camunda.cfg.xml', File.join(bpmn_app_path, 'src/test/resources/camunda.cfg.xml')
        copy_file 'application.properties', File.join(bpmn_app_path, 'src/main/resources/application.properties')
        copy_file 'ProcessScenarioTest.java', File.join(bpmn_app_path, 'src/test/java/unittest/ProcessScenarioTest.java')
        copy_file 'Camunda.java', File.join(bpmn_app_path, 'src/main/java/camunda/Camunda.java')
      end

      def link_resources_folder
        copy_file 'sample.bpmn', File.join(diagram_path, 'sample.bpmn'), ''
        create_link File.join(bpmn_app_path, 'src/main/resources/'), File.join('../../../..', diagram_path)
      end

      def add_to_ignores
        %w[.gitignore .cfignore].each do |file|
          append_to_file file do
            "\n# BPMN Java app\n" +
              File.join(bpmn_app_path, 'target') +
              "\n"
          end
        end
      end

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

      def bpmn_app_path
        options['app_path']
      end

      def diagram_path
        options['diagram_path']
      end
    end
  end
end
