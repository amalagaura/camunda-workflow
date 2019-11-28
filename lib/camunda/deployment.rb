##
# Deployment inherits from the Model class and is responsible for creating BPMN, DMN, add CMMN Models within Camunda.
#

class Camunda::Deployment < Camunda::Model
  collection_path 'deployment'
  # Only supporting .create which uses a POST on deployment/create.
  def self.create(file_names:, tenant_id: nil, deployment_source: 'Camunda Workflow Gem', deployment_name: nil)
    deployment_name ||= file_names.map { |file_name| File.basename(file_name) }.join(", ")
    tenant_id ||= Camunda::Workflow.configuration.tenant_id
    args = file_data(file_names).merge('deployment-name' => deployment_name, 'deployment-source' => deployment_source)
    args.merge!("tenant-id": tenant_id) if tenant_id
    response = post_raw('deployment/create', args)

    deployed_process_definitions(response[:parsed_data][:data][:deployed_process_definitions])
  end

  def self.file_data(file_names)
    file_names.map do |file_name|
      [file_name, UploadIO.new(file_name, 'text/plain')]
    end.to_h
  end

  def self.deployed_process_definitions(definitions_hash)
    # Currently only returning the process definitions. But this Deployment.create can create a DMN, CMMN also
    # It returns :deployed_process_definitions, :deployed_case_definitions, :deployed_decision_definitions,
    # :deployed_decision_requirements_definitions

    raise Camunda::ProcessEngineException, "No Process Definition created" if definitions_hash.nil?

    definitions_hash.values.map { |process_definition| Camunda::ProcessDefinition.new process_definition }
  end
end
