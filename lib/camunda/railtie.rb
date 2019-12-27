module Camunda
  # Railtie that includes rake tasks for camunda-workflow
  class Railtie < Rails::Railtie
    rake_tasks { load "tasks/camunda.rake" }
  end
end
