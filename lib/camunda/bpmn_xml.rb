# Used to parse bpmn file during bpmn_classes generator to create Camunda job class based on process id
class Camunda::BpmnXML
  # @param io_or_string [IO,String] valid xml string for bpmn file
  def initialize(io_or_string)
    @doc = Nokogiri::XML(io_or_string)
  end

  # Friendly name of this BPMN file is the module name
  # @return [String] module name
  def to_s
    module_name
  end

  # @return [String] Id (process definition key) of the BPMN process
  # @example
  #   "CamundaWorkflow"
  def module_name
    @doc.xpath('/bpmn:definitions/bpmn:process').first['id']
  end

  # creates a new instance of Camunda::BpmnXML::Task
  def external_tasks
    @doc.xpath('//*[@camunda:type="external"]').map do |task|
      Task.new(task)
    end
  end

  # We may have tasks with different topics. Returns classes with topics which are the same as the BPMN process id
  # @return [Array<String>] class names which should be implemented
  # @example
  #   ["DoSomething"]
  def class_names_with_same_bpmn_id_as_topic
    tasks_with_same_bpmn_id_as_topic.map(&:class_name)
  end

  # @return [Array<String>] array of modularized class names
  # @example
  #   ["CamundaWorkflow::DoSomething"]
  def modularized_class_names
    class_names_with_same_bpmn_id_as_topic.map { |name| "#{module_name}::#{name}" }
  end

  # @return [Array<String>] topics in this BPMN file
  def topics
    @doc.xpath('//*[@camunda:topic]').map { |node| node.attribute('topic').value }.uniq
  end

  private

  # We may have tasks with different topics.
  # @return [Array<Camunda::BpmnXML::Task>] tasks with topics which are the same as the BPMN process id
  def tasks_with_same_bpmn_id_as_topic
    external_tasks.select { |task| task.topic == module_name }
  end

  # Wrapper for BPMN task XML node
  class Task
    # Stores XML node about a task
    def initialize(task)
      @task = task
    end

    # Extracts class name from Task XML node
    def class_name
      @task.attribute('id').value
    end

    # Extracts topic name from Task XML node
    def topic
      @task.attribute('topic').value
    end
  end
end
