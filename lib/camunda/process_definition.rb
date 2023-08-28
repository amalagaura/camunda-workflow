##
# A process definition defines the structure of a process. The `key` of a process definition is the logical
# identifier of the process. It is used throughout the API, most prominently for starting a process instances.
# The key of a process definition is defined using the `id` property of the corresponding process element in the BPMN XML file.
# @see https://docs.camunda.org/manual/7.7/user-guide/process-engine/process-engine-concepts/
# @see Camunda::ProcessInstance
class Camunda::ProcessDefinition < Camunda::Model
  include Camunda::VariableSerialization
  uri 'process-definition/(:id)'
  # Starts an individual process instance by key and supplies process variables to be included in the process instance. In
  # the example below a business key is provided. A business key is a domain-specific identifier of a process instance,
  # it makes querying for task more efficient. The business key is displayed prominently in applications like Camunda Cockpit.
  # @see https://blog.camunda.com/post/2018/10/business-key/
  # @example
  #   pd = Camunda::ProcessDefinition.start_by_key 'CamundaWorkflow', variables: { x: 'abcd' }, businessKey: 'WorkflowBusinessKey'
  # @param key [String] process definition identifier
  # @param hash [Hash] sets variables to be included with starting a process definition
  # @return [Camunda::ProcessInstance]
  # @raise [Camunda::ProcessEngineException] if submission was unsuccessful
  def self.start_by_key(key, hash={})
    hash[:variables] = serialize_variables(hash[:variables]) if hash[:variables]
    tenant_id = hash.delete(:tenant_id)
    tenant_id ||= Camunda::Workflow.configuration.tenant_id

    response = request(:post, start_path_for_key(key, tenant_id), hash)
    process_instance_result(response)
  end

  # Starts an individual process instance for a process definition. The below example shows how to start a process
  # definition after deployment.
  # @example
  #   pd = Camunda::Deployment.create(file_names: ['bpmn/diagrams/sample.bpmn']).first
  #   pd.start
  # Starts the process instance by sending a request to the Camunda engine
  # @param hash [Hash] defaults to {} if no variables are provided
  # @return [Camunda::ProcessInstance]
  # @raise [Camunda::ProcessEngineException] if submission was unsuccessful
  def start(hash={})
    hash[:variables] = serialize_variables(hash[:variables]) if hash[:variables]
    response = self.class.request(:post, "process-definition/#{id}/start", hash)
    self.class.process_instance_result(response)
  end

  # Sets path to include tenant_id if a tenant_id is provided with a process definition on deployment.
  def self.start_path_for_key(key, tenant_id)
    path = "process-definition/key/#{key}"
    path << "/tenant-id/#{tenant_id}" if tenant_id
    "#{path}/start"
  end

  def self.process_instance_result(response)
    raise Camunda::ProcessEngineException, response.errors["message"] unless response.errors.blank?

    Camunda::ProcessInstance.new response.body["data"]
  end
end
