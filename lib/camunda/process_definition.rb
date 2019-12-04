##
# Camunda::ProcessDefinition allows for the deployment of processes to the process engine. A process
# definition defines the structure of a process. The `key` of a process definition is the logical
# identifier of the process. It is used throughout the API, most prominently for starting a process instances.
# The key of a process definition is defined using the `id` property of the corresponding process element in the BPMN XML file.
#
class Camunda::ProcessDefinition < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'process-definition'
  # Starts the process definition by key and allows variables to be included with the process definition
  # @param [String] key process definition identifier
  # @param [Hash] hash sets variables for a process definition
  # @return [Class] returns an instance of class Camunda::ProcessInstance
  def self.start_by_key(key, hash={})
    hash[:variables] = serialize_variables(hash[:variables]) if hash[:variables]
    tenant_id = hash.delete(:tenant_id)
    tenant_id ||= Camunda::Workflow.configuration.tenant_id

    response = post_raw start_path_for_key(key, tenant_id), hash
    raise Camunda::ProcessEngineException, response[:parsed_data][:data][:message] unless response[:response].status == 200

    Camunda::ProcessInstance.new response[:parsed_data][:data]
  end

  def start(hash={})
    hash[:variables] = serialize_variables(hash[:variables]) if hash[:variables]
    response = self.class.post_raw "process-definition/#{id}/start", hash
    raise Camunda::ProcessEngineException, response[:parsed_data][:data][:message] unless response[:response].status == 200

    Camunda::ProcessInstance.new response[:parsed_data][:data]
  end

  # Sets path if a tenant_id is set in
  def self.start_path_for_key(key, tenant_id)
    path = "process-definition/key/#{key}"
    path << "/tenant-id/#{tenant_id}" if tenant_id
    "#{path}/start"
  end
end
