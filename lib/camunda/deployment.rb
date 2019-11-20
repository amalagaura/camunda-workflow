class Camunda::Deployment < Camunda::Model
  collection_path 'deployment'
  # Only supporting .create which uses a POST on deployment/create.
  # Camunda routes are not proper REST and Her doesn't behave properly if we get a 500 error code either
  def self.create(file_name:, deployment_source: 'Camunda Workflow Gem', deployment_name: nil)
    deployment_name ||= File.basename(file_name)
    args = { 'deployment-name' => deployment_name, 'deployment-source' => deployment_source,
             data: UploadIO.new(file_name, 'text/plain') }
    post_raw('deployment/create', args).tap do |response|
      raise Camunda::ProcessEngineException, response[:parsed_data][:data][:message] if response[:response].status != 200
    end
  end
end
