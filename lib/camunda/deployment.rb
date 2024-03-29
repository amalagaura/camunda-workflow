# Deployment is responsible for creating BPMN, DMN, and CMMN processes within Camunda. Before a process (or case, or decision)
# can be executed by the process engine, it has to be deployed. A deployment is a logical entity that groups multiple resources
# that are deployed together. Camunda offers an application called Modeler(https://camunda.com/download/modeler/) that allows you
# to create and edit BPMN diagrams and BPMN decision tables.
# @see https://docs.camunda.org/manual/7.4/user-guide/process-engine/deployments/
# @note You must supply the paths of the BPMN files as a param titled file_names to deploy the BPMN file
# and deploy BPMN, DMN, CMMN definitions in the Camunda engine.
class Camunda::Deployment < Camunda::Model
  uri 'deployment/(:id)'

  # Deploys a new process definition to Camunda and returns an instance of Camunda::ProcessDefinition.
  # @note Only supporting .create which uses a POST on deployment/create.
  # @example
  #   pd = Camunda::Deployment.create(file_names: ['bpmn/resources/sample.bpmn']).first
  # @param files_names [Array<String>] file paths of the bpmn file for deployment
  # @param tenant_id [String] supplied when a single Camunda installation should serve more than one tenant
  # @param deployment_source [String] the source of where the deployment occurred.
  # @param deployment_name [String] provide the name of the deployment, otherwise the deployment name will be the bpmn file names.
  # @return [Camunda::ProcessDefinition]
  def self.create(file_names:, tenant_id: nil, deployment_source: 'Camunda Workflow Gem', deployment_name: nil)
    deployment_name ||= file_names.map { |file_name| File.basename(file_name) }.join(", ")
    tenant_id ||= Camunda::Workflow.configuration.tenant_id
    args = file_data(file_names).merge('deployment-name' => deployment_name, 'deployment-source' => deployment_source)
    args.merge!('tenant-id': tenant_id) if tenant_id
    response = request(:post, "deployment/create", args)
    deployed_process_definitions(response.body[:data][:deployed_process_definitions])
  end

  # Convenience method for dealing with files and IO that are to be uploaded
  # @param file_names [Array<String>] local files paths to be uploaded
  def self.file_data(file_names)
    file_names.map do |file_name|
      [file_name, Faraday::FilePart.new(file_name, 'text/plain')]
    end.to_h
  end

  # Returns a new instance of Camunda::ProcessDefinition according to definitions hash returned by Camunda
  # @raise [ProcessEngineException] if process definition is nil
  # @param definitions_hash [Hash]
  # @return [Array<Camunda::ProcessDefinition>]
  def self.deployed_process_definitions(definitions_hash)
    # Currently only returning the process definitions. But this Deployment.create can create a DMN, CMMN also
    # It returns :deployed_process_definitions, :deployed_case_definitions, :deployed_decision_definitions,
    # :deployed_decision_requirements_definitions

    raise Camunda::ProcessEngineException, "No Process Definition created" if definitions_hash.nil?

    definitions_hash.values.map { |process_definition| Camunda::ProcessDefinition.new process_definition }
  end

  def destroy(params={})
    self.attributes = delete(params)
  end
end
