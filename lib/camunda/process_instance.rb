class Camunda::ProcessInstance < Camunda::Model
  collection_path 'process-instance'

  def variables
    response = self.class.get_raw "process-instance/#{id}/variables"
    deserialize_variables response[:parsed_data][:data]
  end

  private

  def deserialize_variables(hash)
    hash.transform_values do |value_hash|
      case value_hash[:type]
      when "String", "Double", "Integer", "Boolean"
        value_hash[:value]
      when "Json"
        value_hash[:value][:node_type]
      end
    end
  end
end
