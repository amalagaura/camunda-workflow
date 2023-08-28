# Allows for incidents to be reported to Camunda. Incidents are notable events
# that happen in the process engine. Such incidents usually indicate some kind of problem
# related to process execution. Incidents are reported on failures that occur.
class Camunda::Incident < Camunda::Model
  uri 'incident/(:id)'
end
