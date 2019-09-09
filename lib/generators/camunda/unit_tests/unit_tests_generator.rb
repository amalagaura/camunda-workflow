module Camunda
  module Generators
    class UnitTestsGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)
      class_option :app_path, type: :string, default: 'bpmn/java_app'
      class_option :diagram_path, type: :string, default: 'bpmn/diagrams'

      def copy_java_app_files
        copy_file 'pom.xml', File.join(bpmn_app_path, 'pom.xml')
        copy_file 'camunda.cfg.xml', File.join(bpmn_app_path, 'src/test/resources/camunda.cfg.xml')
        copy_file 'SampleBPMNTest.java', File.join(bpmn_app_path, 'src/test/java/unittest/SampleBPMNTest.java')
      end

      def link_resources_folder
        copy_file 'sample.bpmn', File.join(diagram_path, 'sample.bpmn'), ''
        create_link File.join(bpmn_app_path, 'src/main/resources/'), File.join('../../../..', diagram_path)
      end

      def maven_settings_xml
        copy_file 'settings.xml', File.join(ENV['HOME'], '.m2', 'settings.xml')
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


      def output_instructions
        unit_test_path = File.join(bpmn_app_path, 'src/test/java/unittest/')
        puts set_color("\nCreate your tests in #{unit_test_path} and run `mvn clean test` in #{bpmn_app_path}", :red)
        puts set_color("You can delete the sample tests and sample bpmn resource if you don't require the examples", :green)
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
