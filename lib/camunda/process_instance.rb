##
# A process instance is an individual execution of a process definition. The relation of the process instance to the process
# definition is the same as the relation between Object and Class in OOP.
class Camunda::ProcessInstance < Camunda::Model
  collection_path 'process-instance'
  # GETs the process instance and deserializes the variables
  def variables
    response = self.class.get_raw "process-instance/#{id}/variables"
    deserialize_variables response[:parsed_data][:data]
  end

  private

  # deserialize variables from CamelCase to snake_case
  # @param [Hash] hash takes the process instance variables and deserializes them back to snake_case
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
