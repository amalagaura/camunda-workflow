require 'active_support/concern'
module Camunda
  # The VariableSerialization module adds information to variables so Camunda can parse them. It adds types annotations and
  # serializes hashes and array to JSON. Camunda engine cannot search on snake_case variables so it changes variable names
  # to camelCase.
  # @see Camunda::ProcessDefinition
  module VariableSerialization
    extend ActiveSupport::Concern
    # Wrapper for class level method
    def serialize_variables(variables)
      self.class.serialize_variables(variables)
    end

    class_methods do
      # rubocop:disable Metrics/MethodLength
      # @param variables [Hash]
      # @return {String,Symbol => {String,Symbol => Object}}
      def serialize_variables(variables)
        hash = variables.transform_values do |value|
          case value
          when String
            { value: value, type: 'String' }
          when Array, Hash
            { value: transform_json(value).to_json, type: 'Json' }
          when TrueClass, FalseClass
            { value: value, type: 'Boolean' }
          when Integer
            { value: value, type: 'Integer' }
          when Float
            { value: value, type: 'Double' }
          else
            raise ArgumentError, "Not supporting complex types yet"
          end
        end
        camelcase_keys(hash)
      end

      # rubocop:enable Metrics/MethodLength
      # Transforms keys of a JSON like object (Array,Hash) from snake_case to CamelCase
      # @param json [Array,Hash]
      # @return [Hash] returns hash with camelCase keys
      def transform_json(json)
        if json.is_a?(Array)
          json.map { |element| transform_json(element) }
        elsif json.is_a?(Hash)
          camelcase_keys(json)
        else
          json
        end
      end

      def camelcase_keys(hash)
        hash.deep_transform_keys { |key| key.to_s.camelcase(:lower) }
      end
    end
  end
end
