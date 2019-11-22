class Camunda::ProcessDefinition < Camunda::Model
  include Camunda::VariableSerialization
  collection_path 'process-definition'

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

  def self.start_path_for_key(key, tenant_id)
    path = "process-definition/key/#{key}"
    path << "/tenant-id/#{tenant_id}" if tenant_id
    "#{path}/start"
  end
end
