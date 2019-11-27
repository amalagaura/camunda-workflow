# Overwriting default engine prefix because we don't use the default rest-engine prefix given by the default Camunda
# distribution. We have been using the spring boot app which uses 'rest'.
# This will need to be in a more configurable place if developers of this gem need to adjust this.

Camunda::Workflow.configure do |config|
  config.engine_route_prefix = 'rest'
end
