RSpec.describe Camunda::ExternalTask do
  before do
    do_something = Class.new do
      def self.perform_now(_id, variables)
        variables
      end

      def self.perform_later(_id, _variables)
        "Job Queued"
      end
    end
    stub_const('CamundaTest::DoSomething', do_something)
  end

  let(:variables) { { s: "string", foo: { bar: { a: "baz" } } } }
  let(:task) do
    described_class.new activity_id: "DoSomething", process_definition_key: "CamundaTest",
                        variables: described_class.serialize_variables(variables)
  end

  describe 'run Camunda::ExternalTask' do
    it("de-serializes") { expect(task.variables).to eq(variables.deep_stringify_keys) }
    it('queues task') { expect(task.queue_task).to eq("Job Queued") }
    it('finds task class name') { expect(task.task_class_name).to eq("CamundaTest::DoSomething") }
    it('runs fetched tasks with Json') { expect(task.run_now).to eq(variables.deep_stringify_keys) }

    it 'fails with no class' do
      fail_task = described_class.new(activity_id: "NoClass", process_definition_key: "NoWorkflow", variables: {})
      expect { fail_task.task_class }.to raise_error(Camunda::MissingImplementationClass)
    end
  end

  describe 'default initializers are set in Workflow configuration' do
    it('has a default long_polling_duration of 30000') { expect(described_class.long_polling_duration).to eq(30_000) }
    it('has default max_polling_tasks of 2') { expect(described_class.max_polling_tasks).to eq(2) }
    it('has a default lock_duration') { expect(described_class.lock_duration).to eq(1_209_600_000) }
  end
end
