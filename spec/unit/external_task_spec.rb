require 'camunda/workflow'
require 'camunda/model'
require 'camunda/external_task'

RSpec.describe Camunda::ExternalTask do

    it 'fetch tasks' do
      tasks = Camunda::ExternalTask.fetch_and_lock(%w[CamundaWorkflow])
      expect(tasks).not_to be_empty
      p tasks
      expect(tasks[:response].status).to eq(200)
  end

  it 'should run fetched tasks' do
    run_tasks = tasks.each { |task|  task.task_class_name.safe_constantize.perform_now task.id, task.variables }

  end
end
