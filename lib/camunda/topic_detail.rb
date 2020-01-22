module Camunda
  # PORO to represent request for topics as used in the fetchAndLock API call
  # @see https://docs.camunda.org/manual/7.12/reference/rest/external-task/fetch/#request-body
  class TopicDetail
    # Mandatory. The topic's name.
    attr_accessor :topic_name
    # Mandatory. The duration to lock the external tasks for in milliseconds.
    attr_accessor :lock_duration
    # A JSON array of String values that represent variable names. For each result task belonging to this topic,
    # the given variables are returned as well if they are accessible from the external task's execution.
    # If not provided - all variables will be fetched.
    attr_accessor :variables
    # If true only local variables will be fetched.
    attr_accessor :local_variables
    # A String value which enables the filtering of tasks based on process instance business key.
    attr_accessor :business_key
    # Filter tasks based on process definition id.
    attr_accessor :process_definition_id
    # Filter tasks based on process definition ids.
    attr_accessor :process_definition_id_in
    # Filter tasks based on process definition key.
    attr_accessor :process_definition_key
    # Filter tasks based on process definition keys.
    attr_accessor :process_definition_key_in
    # Filter tasks based on process definition version tag.
    attr_accessor :process_definition_version_tag
    # Filter tasks without tenant id.
    attr_accessor :without_tenant_id
    # Filter tasks based on tenant ids.
    attr_accessor :tenant_id_in
    # A JSON object used for filtering tasks based on process instance variable values. A property name of the object
    # represents a process variable name, while the property value represents the process variable value to filter tasks by.
    attr_accessor :process_variables
    # Determines whether serializable variable values (typically variables that store custom Java objects) should be
    # deserialized on server side (default false). If set to true, a serializable variable will be deserialized on
    # server side and transformed to JSON using Jackson's POJO/bean property introspection feature. Note that this
    # requires the Java classes of the variable value to be on the REST API's classpath. If set to false, a serializable
    # variable will be returned in its serialized format. For example, a variable that is serialized as XML will be
    # returned as a JSON string containing XML.
    attr_accessor :deserialize_values

    def initialize(topic_name, lock_duration=default_lock_duration)
      @topic_name = topic_name
      @lock_duration = lock_duration
    end

    def default_lock_duration
      Camunda::Workflow.configuration.lock_duration
    end

    # rubocop:disable Metrics/MethodLength
    def to_h
      hash = {
        topicName: topic_name,
        lockDuration: lock_duration,
        variables: variables,
        localVariables: local_variables,
        businessKey: business_key,
        processDefinitionId: process_definition_id,
        processDefinitionIdIn: process_definition_id_in,
        processDefinitionKey: process_definition_key,
        processDefinitionKeyIn: process_definition_key_in,
        processDefinitionVersionTag: process_definition_version_tag,
        withoutTenantId: without_tenant_id,
        tenantIdIn: tenant_id_in,
        processVariables: process_variables,
        deserializeValues: deserialize_values
      }

      # remove all empty values
      hash.reject { |_, val| val.nil? }
      # rubocop:enable Metrics/MethodLength
    end
  end
end
