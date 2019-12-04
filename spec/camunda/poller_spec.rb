RSpec.describe Camunda::Poller, :vcr, :deployment do
  before do
    Camunda::ProcessDefinition.start_by_key definition_key, variables: { x: 'abcd' }, businessKey: 'Key'
    # We are testing code in an infinite loop so we have to stub the loop
    allow(described_class).to receive(:loop).and_yield
  end

  let(:klass) do
    Class.new do
      include Camunda::ExternalTaskJob

      def self.perform_later(*args)
        new.perform(*args)
      end

      def bpmn_perform(variables)
        variables
      end
    end
  end

  describe '#fetch_and_execute' do
    it 'completes a task' do
      expect(Camunda::ExternalTask.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id).count).to eq(1)
      stub_const('CamundaWorkflow::DoSomething', klass)
      described_class.fetch_and_execute(%w[CamundaWorkflow])
      expect(Camunda::ExternalTask.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id).count).to eq(0)
    end

    it 'reports missing classes' do
      expect(Camunda::Incident.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id).count).to eq(0)
      expect(Camunda::ExternalTask.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id, notLocked: true).count).to eq(1)
      described_class.fetch_and_execute(%w[CamundaWorkflow])
      expect(Camunda::Incident.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id).count).to eq(1)
    end
  end
end
