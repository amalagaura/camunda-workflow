RSpec.describe Camunda::ExternalTask do
  module CamundaTest
    class DoSomething
      def self.perform_now(_id, variables)
        variables
      end

      def self.perform_later(_id, _variables)
        "Job Queued"
      end
    end
  end

  let(:variables) { { s: "string", foo: { bar: { a: "baz" } } } }
  let(:task) do
    Camunda::ExternalTask.new activity_id: "DoSomething", process_definition_key: "CamundaTest",
                              variables: Camunda::ExternalTask.serialize_variables(variables)
  end

  context 'run Camunda::ExternalTask' do
    it("de-serializes") { expect(task.variables).to eq(variables.deep_stringify_keys) }
    it('should queue task') { expect(task.queue_task).to eq("Job Queued") }
    it('finds task class name') { expect(task.task_class_name).to eq("CamundaTest::DoSomething") }
    it('should run fetched tasks with Json') { expect(task.run_now).to eq(variables.deep_stringify_keys) }
    it 'should fail with no class' do
      fail_task = Camunda::ExternalTask.new(activity_id: "NoClass", process_definition_key: "NoWorkflow", variables: {})
      expect { fail_task.task_class }.to raise_error(Camunda::MissingImplementationClass)
    end
  end
  context 'default initializers are set in Workflow configuration' do
    it('has a default long_polling_duration of 30000') { expect(Camunda::ExternalTask.long_polling_duration).to eq(30_000) }
    it('has default max_polling_tasks of 2') { expect(Camunda::ExternalTask.max_polling_tasks).to eq(2) }
    it('has a default lock_duration') { expect(Camunda::ExternalTask.lock_duration).to eq(1_209_600_000) }
  end
end
