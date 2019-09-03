require_relative '../camunda.rb'
%w[../camunda.rb model.rb external_task.rb external_task_job.rb poller.rb process_definition.rb process_instance.rb bpmn_xml.rb]
  .each do |file|
  require File.join(__dir__, file)
end
