# Runs Camunda spring-boot commands using rake.

task default: %w[run]

namespace :camunda do
  # Path for the spring boot application.
  mvn_path = 'bpmn/java_app'

  # Starts the camunda engine e.g. mvn spring-boot:run.
  desc 'Starts the Camunda spring-boot application.'
  task :run do
    system('mvn spring-boot:run', chdir: mvn_path)
  end

  # Runs spring boot test suite e.g. mvn test.
  desc 'Runs test suite for Camunda spring-boot application'
  task :test do
    system('mvn test', chdir: mvn_path)
  end
  # Installs the spring-boot app dependencies mvn clean install.
  desc 'Installs spring-boot dependencies for Camunda spring-boot app.'
  task :install do
    system('mvn clean install', chdir: mvn_path)
  end
end
