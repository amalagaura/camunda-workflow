require 'active_support/concern'
module Camunda
  # Camunda engine doesn't handle snake_case variables, the VariableSerialization module
  # serializes variables sent to Camunda engine and transforms them to CamelCase.
  module VariableSerialization
    extend ActiveSupport::Concern

    def serialize_variables(variables)
      self.class.serialize_variables(variables)
    end

    class_methods do
      # rubocop:disable Metrics/MethodLength
      # @param [Hash] variables
      # @return [Object]
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
