# Deployment is responsible for creating BPMN, DMN, add CMMN processes within Camunda. Before a process (or case, or decision)
# can be executed by the process engine, it has to be deployed. A deployment is a logical entity that groups multiple resources
# that are deployed together. Camunda offers an application called Modeler(https://camunda.com/download/modeler/) that allows you
# to create and edit BPMN diagrams and BPMN decision tables.
# @see https://docs.camunda.org/manual/7.4/user-guide/process-engine/deployments/
# @note You must supply the paths of the BPMN files as a param titled file_names to deploy the BPMN file
# and create a process definition in the Camunda engine.
class Camunda::Deployment < Camunda::Model
  collection_path 'deployment'
  # Deploys a new process definition to Camunda and returns an instance of Camunda::ProcessDefinition.
  # @note Only supporting .create which uses a POST on deployment/create.
  # @example
  #   pd = Camunda::Deployment.create(file_names: ['bpmn/diagrams/sample.bpmn']).first
  # @param file_names [Array<String>] file paths of the bpmn file for deployment
  # @param tenant_id [String] supplied when a single Camunda installation should serve more than one tenant
  # @param deployment_source [String] the source of where the deployment occurred.
  # @param [String] deployment_name provide the name of the deployment, otherwise the deployment name will be the bpmn file name.
  # @return [Camunda::ProcessDefinition]
  def self.create(file_names:, tenant_id: nil, deployment_source: 'Camunda Workflow Gem', deployment_name: nil)
    deployment_name ||= file_names.map { |file_name| File.basename(file_name) }.join(", ")
    tenant_id ||= Camunda::Workflow.configuration.tenant_id
    args = file_data(file_names).merge('deployment-name' => deployment_name, 'deployment-source' => deployment_source)
    args.merge!("tenant-id": tenant_id) if tenant_id
    response = post_raw('deployment/create', args)

    deployed_process_definitions(response[:parsed_data][:data][:deployed_process_definitions])
  end

  # Convenience method for dealing with files and IO that are to be uploaded
  # @param [Array<String>] file_names local files paths to be uploaded
  def self.file_data(file_names)
    file_names.map do |file_name|
      [file_name, UploadIO.new(file_name, 'text/plain')]
    end.to_h
  end

  # Creates a new instance of Camunda::ProcessDefinition for each definition uploaded
  # @raise  [ProcessEngineException] raises error if process definition is nil
  # @param [Hash] definitions_hash
  def self.deployed_process_definitions(definitions_hash)
    # Currently only returning the process definitions. But this Deployment.create can create a DMN, CMMN also
    # It returns :deployed_process_definitions, :deployed_case_definitions, :deployed_decision_definitions,
    # :deployed_decision_requirements_definitions

    raise Camunda::ProcessEngineException, "No Process Definition created" if definitions_hash.nil?

    definitions_hash.values.map { |process_definition| Camunda::ProcessDefinition.new process_definition }
  end
end
