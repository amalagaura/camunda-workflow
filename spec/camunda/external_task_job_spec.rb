RSpec.describe Camunda::ExternalTaskJob, :deployment, :vcr do
  let!(:process_instance) { Camunda::ProcessDefinition.start_by_key definition_key, businessKey: 'Key' }
  let(:task) { Camunda::ExternalTask.fetch_and_lock("CamundaWorkflow").first }

  # We are running a class as the external task implementation. We are ignoring the Camunda activityId class
  let(:external_task_job) { klass.new.perform(task.id, x: 'abcd') }

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
      expect(external_task_job.errors).to be_blank
      expect { Camunda::ExternalTask.find(task.id) }.to raise_error(Spyke::ResourceNotFound)
      # Expect the process instance to have it's variables updated
      expect(process_instance.variables.symbolize_keys).to eq(x: 'abcd')
    end

    context 'when submission error' do
      let(:task) { Camunda::ExternalTask.fetch_and_lock("CamundaWorkflowErrors").first }

      it('bpmn error in submitting gives an error description') do
        expect do
          external_task_job
        end
          .to raise_error(
            Camunda::ExternalTask::SubmissionError,
            /Unknown property used in expression: \${missingVariable}. Cause: Cannot resolve identifier 'missingVariable'/
          )
      end
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
      expect(external_task_job.errors).to be_blank
      incident = Camunda::Incident.find_by!(processInstanceId: process_instance.id, activityId: task.activity_id)
      expect(incident).to be_an_instance_of(Camunda::Incident)
      expect(incident.incident_message).to eq("This broke")
      expect(incident.incident_message).not_to include("activesupport")
      Camunda::Workflow.configuration.backtrace_silencer_lines.each do |silenced_line|
        expect(incident.incident_message).not_to include(silenced_line)
      end
    end
  end

  context 'when no bpmn_perform' do
    let(:klass) { Class.new { include Camunda::ExternalTaskJob } }

    it '#bpmn_perform' do
      expect(external_task_job.errors).to be_blank
      incident = Camunda::Incident.find_by!(processInstanceId: process_instance.id, activityId: task.activity_id)
      expect(incident).to be_an_instance_of(Camunda::Incident)
      expect(incident.incident_message)
        .to eq("Please define this method which takes a hash of variables and returns a hash of variables")
    end
  end

  context "when bpmn_perform doesn't return variables" do
    let(:klass) do
      Class.new do
        include Camunda::ExternalTaskJob

        def bpmn_perform(_variables)
          []
        end
      end
    end

    it '#bpmn_perform' do
      expect(external_task_job.errors).to be_blank
      expect { Camunda::ExternalTask.find(task.id) }.to raise_error(Spyke::ResourceNotFound)
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
      expect(external_task_job.errors).to be_blank
      expect { Camunda::ExternalTask.find(task.id) }.to raise_error(Spyke::ResourceNotFound)
      expect(process_instance.variables).to eq("bpmn" => "error")
    end
  end
end
