shared_context "with default context" do
  let(:definition_key) { 'CamundaWorkflow' }
end

RSpec.configure do |config|
  config.include_context "with default context"
end
