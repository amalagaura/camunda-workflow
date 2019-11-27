shared_context "default context" do
  let(:definition_key) { 'CamundaWorkflow' }
end

RSpec.configure do |config|
  config.include_context "default context"
end
