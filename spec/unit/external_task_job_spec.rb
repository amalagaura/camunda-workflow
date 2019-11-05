require 'camunda/workflow'
require 'camunda/model'
require 'camunda/external_task_job'
RSpec.describe Camunda::ExternalTaskJob do
  let(:job) { instance_double(Camunda::ExternalTaskJob) }
  context 'process active job' do
    it 'performs jobs' do
      expect(job).to receive(:perform).and_return("object")
      run_task = job.perform(5, {})
      expect(run_task).to eq("object")
    end
    it '#report_completion' do
      allow(job).to receive(:report_completion)
    end
  end
end
