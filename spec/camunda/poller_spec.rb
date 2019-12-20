RSpec.describe Camunda::Poller, :vcr do
  describe '#fetch_and_queue' do
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

    it 'completes a task' do
      expect(Camunda::ExternalTask.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id).count).to eq(2)
      stub_const('CamundaWorkflow::DoSomething', klass)
      described_class.fetch_and_queue(%w[CamundaWorkflow])
      expect(Camunda::ExternalTask.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id).count).to eq(1)
    end

    it 'reports missing classes' do
      expect(Camunda::Incident.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id).count).to eq(0)
      expect(Camunda::ExternalTask.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id, notLocked: true).count).to eq(2)
      described_class.fetch_and_queue(%w[CamundaWorkflow])
      expect(Camunda::Incident.where(tenantIdIn: Camunda::Workflow.configuration.tenant_id).count).to eq(1)
    end
  end

  describe '#fetch_and_execute', vcr: false do
    it "pass on with a deprecation" do
      allow(described_class).to receive(:fetch_and_queue)
      allow(described_class).to receive(:warn)
      described_class.fetch_and_execute(%w[CamundaWorkflow])
      expect(described_class).to have_received(:fetch_and_queue)
      expect(described_class).to have_received(:warn)
    end
  end
end
