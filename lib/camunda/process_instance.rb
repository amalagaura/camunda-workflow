# A process instance is an individual execution of a process definition. The relation of the process instance to the process
# definition is the same as the relation between Class and Class instance in OOP. When a process definition is started,
# a process instance is created.
# @see https://docs.camunda.org/manual/7.4/user-guide/process-engine/process-engine-concepts/
# @see Camunda::ProcessDefinition
class Camunda::ProcessInstance < Camunda::Model
  uri 'process-instance/(:id)'
  # GETs the process instance and deserializes the variables
  def variables
    response = self.class.request(:get, "process-instance/#{id}/variables")
    deserialize_variables response.body[:data]
  end

  private

  # Deserialize variables and convert variable names from CamelCase to snake_case.
  # @param hash [Hash] Transforms a hash of Camunda serialized variables to a simple Ruby hash and snake_cases variable names
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
