require 'camunda/workflow'
require 'camunda/model'
require 'camunda/variable_serialization'
require 'camunda/external_task'

RSpec.describe Camunda::ExternalTask do
  module CamundaWorkflow
    class DoSomething
      def self.perform_now(_id, variables)
        variables
      end
    end
  end

  let (:task) do
    Camunda::ExternalTask.new(activity_id: "DoSomething", process_definition_key: "CamundaWorkflow",
                              variables: { "foo" => { "type" => "Json", "value" => { "bar" => "baz" }.to_json } })
  end
  let(:tasks) { Camunda::ExternalTask.fetch_and_lock(%w[CamundaWorkflow]) }
  let(:fail_task) { Camunda::ExternalTask.fetch_and_lock(%()) }
  context 'fetch and run external tasks from Camunda' do
    it 'should run fetched tasks' do
      expect(task.run_now).to eq("foo" => { "bar" => "baz" })
    end

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
