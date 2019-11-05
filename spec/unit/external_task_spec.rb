require 'camunda/workflow'
require 'camunda/model'
require 'camunda/variable_serialization'
require 'camunda/external_task'

RSpec.describe Camunda::ExternalTask do
  let(:tasks) { Camunda::ExternalTask.fetch_and_lock(%w[CamundaWorkflow]) }
  let(:run_tasks) { instance_double(Camunda::ExternalTask) }
  context 'fetch and run external tasks from Camunda' do
    it 'fetch tasks' do
      VCR.use_cassette('external_task_fetch_and_lock') do
        expect(tasks).not_to be_empty
        expect(tasks.size).to eq(2)
      end
    end

    it 'should run fetched tasks' do
      allow(run_tasks).to receive(:run_now).and_return("Array of objects")
      results = run_tasks.run_now
      expect(results).to eq("Array of objects")
    end

    it 'should queue task' do
      allow(run_tasks).to receive(:queue_task).and_return("Queue task to perform later")
      task = run_tasks.queue_task
      expect(task).to eq("Queue task to perform later")
    end

    it 'creates task class name for perform' do
      VCR.use_cassette('get_external_tasks_check_class_name') do
        task = Camunda::ExternalTask.all.first
        class_name = task.task_class_name
        expect(class_name).to eq("CamundaWorkflow::DoSomething")
      end
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
  context 'reports on failure' do
    it 'if a failure occurs report throw exception' do
      allow(run_tasks).to receive(:report_failure).with(error: "Exception").and_return("Exception from Camunda")
    end
  end
end
