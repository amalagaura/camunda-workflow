require 'vcr'
VCR.configure do |c|
  c.cassette_library_dir = 'spec/vcr'
  c.hook_into :faraday
  # Default VCR rspec metadata causes let() and before() and spec cassettes to be stored in different directories
  # c.configure_rspec_metadata!
  c.allow_http_connections_when_no_cassette = true
end

RSpec.configure do |config|
  def tenant_id
    Camunda::Workflow.configuration.tenant_id
  end

  def clear_camunda
    Camunda::ProcessInstance.where(tenantIdIn: tenant_id).each(&:destroy)
    Camunda::Incident.where(tenantIdIn: tenant_id).each(&:destroy)
  end

  # Add VCR to tests with :vcr metadata
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(%r{[^\w/]+}, "_")
    options = example.metadata.slice(:record, :match_requests_on).except(:example_group)
    VCR.use_cassette(name, options) do
      if example.metadata[:deployment]
        Camunda::Deployment.create(file_names: ['spec/bpmn_test_files/sample.bpmn'], tenant_id: tenant_id)
      end

      # Allow us to override :vcr individually with vcr: false
      if example.metadata[:vcr]
        clear_camunda
        result = example.run

        # Leave Process Instances and Deployments available for failed examples. This will not work though unless you run only the
        # failing example because a subsequent successful spec will clear the Process Instances and Deployments
        if result.nil?
          clear_camunda
          if example.metadata[:deployment]
            Camunda::Deployment.where(tenantIdIn: tenant_id).each { |deployment| deployment.destroy(cascade: true) }
          end
        end
      end
    end
  end
end
