RSpec.describe Camunda::ExternalTaskJob, :vcr, :deployment do
  let!(:process_instance) { Camunda::ProcessDefinition.start_by_key 'CamundaWorkflow', businessKey: 'Key' }
  let(:task) { Camunda::ExternalTask.fetch_and_lock("CamundaWorkflow").first }

  # We are running a class as the external task implementation. We are ignoring the Camunda activityId class
  let(:subject) { klass.new.perform(task.id, x: 'abcd') }

  context 'when valid external task' do
    let(:klass) do
      Class.new do
        include Camunda::ExternalTaskJob

        def bpmn_perform(variables)
          variables
        end
      end
    end
    it '#completion' do
      expect(Camunda::ExternalTask.find(task.id)).to be_an_instance_of(Camunda::ExternalTask)
      is_expected.to be_success
      expect(Camunda::ExternalTask.find(task.id)).to be_nil
      # Expect the process instance to have it's variables updated
      expect(process_instance.variables).to eq(x: 'abcd')
    end
  end

  context 'when incident with error' do
    let(:klass) do
      Class.new do
        include Camunda::ExternalTaskJob

        def bpmn_perform(_variables)
          raise StandardError, "This broke"
        end
      end
    end
    it '#failure' do
      is_expected.to be_success
      incident = Camunda::Incident.find_by(processInstanceId: process_instance.id, activityId: task.activity_id)
      expect(incident).to be_an_instance_of(Camunda::Incident)
      expect(incident.incident_message).to eq("This broke")
    end
  end
  context 'when no bpmn_perform' do
    let(:klass) { Class.new { include Camunda::ExternalTaskJob } }

    it '#bpmn_perform' do
      is_expected.to be_success
      incident = Camunda::Incident.find_by(processInstanceId: process_instance.id, activityId: task.activity_id)
      expect(incident).to be_an_instance_of(Camunda::Incident)
      expect(incident.incident_message)
        .to eq("Please define this method which takes a hash of variables and returns a hash of variables")
    end
  end
  context 'when has bpmn error' do
    let(:klass) do
      Class.new do
        include Camunda::ExternalTaskJob

        def bpmn_perform(_variables)
          raise Camunda::BpmnError.new error_code: 'bpmn-error', message: "Special BPMN error", variables: { bpmn: 'error' }
        end
      end
    end

    it '#bpmn_error' do
      is_expected.to be_success
      expect(Camunda::ExternalTask.find(task.id)).to be_nil
      expect(process_instance.variables).to eq(bpmn: 'error')
    end
  end
end
