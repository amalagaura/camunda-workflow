RSpec.describe Camunda::ExternalTask do
  module CamundaWorkflow
    class DoSomething
      def self.perform_now(_id, variables)
        variables
      end

      def self.perform_later(_id, variables)
        variables
      end
    end
  end

  let(:task) do
    Camunda::ExternalTask.new(activity_id: "DoSomething", process_definition_key: "CamundaWorkflow",
                              variables: { "foo" => { "type" => "Json", "value" => { "bar" => "baz" }.to_json } })
  end

  let(:task_string) do
    Camunda::ExternalTask.new(activity_id: "DoSomething", process_definition_key: "CamundaWorkflow",
                              variables: { "foo" => { "type" => "String", "value" => "barBaz" } })
  end
  let(:tasks) { Camunda::ExternalTask.fetch_and_lock(%w[CamundaWorkflow]) }

  context 'fetch and run external tasks from Camunda' do
    it('should run fetched tasks with Json') { expect(task.run_now).to eq("foo" => { "bar" => "baz" }) }
    it('should run fetched task with a String') { expect(task_string.run_now).to eq("foo" => "barBaz") }
    it 'should fail with no class' do
      fail_task = Camunda::ExternalTask.new(activity_id: "NoClass", process_definition_key: "NoWorkflow", variables: {})
      expect { fail_task.task_class }.to raise_error(Camunda::MissingImplementationClass)
    end
    it('should queue task') { expect(task.queue_task).to eq("foo" => { "bar" => "baz" }) }
    it 'creates task class name for perform' do
      class_name = task.task_class_name
      expect(class_name).to eq("CamundaWorkflow::DoSomething")
    end
  end
  context 'default initializers are set in Workflow configuration' do
    it 'has a default long_polling_duration of 30000' do
      polling_duration = Camunda::ExternalTask.long_polling_duration
      expect(polling_duration).to eq(30_000)
    end

    it 'has default max_polling_tasks of 2' do
      polling_tasks = Camunda::ExternalTask.max_polling_tasks
      expect(polling_tasks).to eq(2)
    end

    it 'has a default lock_duration' do
      lock_duration = Camunda::ExternalTask.lock_duration
      expect(lock_duration).to eq(1_209_600_000)
    end
  end
end
