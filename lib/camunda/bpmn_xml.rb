class Camunda::BpmnXML
  attr_reader :doc

  # @param io_or_string [IO,String] valid xml string for bpmn file
  def initialize(io_or_string)
    @doc = Nokogiri::XML(io_or_string)
  end

  # @return [String]
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

  # @return [Array<String>] returns an array with the topic as a string
  # @example
  #   ["DoSomething"]
  def class_names_with_same_bpmn_id_as_topic
    tasks_with_same_bpmn_id_as_topic.map(&:class_name)
  end

  # @return [Array<String>] returns an array with a modularized class name as a string
  # @example
  #   ["CamundaWorkflow::DoSomething"]
  def modularized_class_names
    class_names_with_same_bpmn_id_as_topic.map { |name| "#{module_name}::#{name}" }
  end

  # @return [Array]
  def topics
    @doc.xpath('//*[@camunda:topic]').map { |node| node.attribute('topic').value }.uniq
  end

  private

  # @return [Object] returns an instance of Camunda::BpmnXML::Task
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
