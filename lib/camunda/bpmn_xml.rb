class Camunda::BpmnXML
  def initialize(io_or_string)
    @doc = Nokogiri::XML(io_or_string)
  end

  def module_name
    @doc.xpath('/bpmn:definitions/bpmn:process').first['id']
  end

  def external_tasks
    @doc.xpath('//*[@camunda:type="external"]').map do |task|
      Task.new(task)
    end
  end

  def class_names_with_same_bpmn_id_as_topic
    tasks_with_same_bpmn_id_as_topic.map(&:class_name)
  end

  def modularized_class_names
    class_names_with_same_bpmn_id_as_topic.map { |name| "#{module_name}::#{name}" }
  end

  def topics
    @doc.xpath('//*[@camunda:topic]').map { |node| node.attribute('topic').value }.uniq
  end

  private

  def tasks_with_same_bpmn_id_as_topic
    external_tasks.select { |task| task.topic == module_name }
  end

  class Task
    def initialize(task)
      @task = task
    end

    def class_name
      @task.attribute('id').value
    end

    def topic
      @task.attribute('topic').value
    end
  end
end
