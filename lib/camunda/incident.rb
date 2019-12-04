##
# Allows for incidents to reported to Camunda. Incidents are notable events
# that happen in the process engine. Such incidents usually indicate some kind of problem
# related to process execution.
class Camunda::Incident < Camunda::Model
  collection_path 'incident'
end
