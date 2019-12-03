# All of the BPMN worker classes will inherit from this class
class CamundaJob < ApplicationJob
  # If using Sidekiq change to include Sidekiq::Worker instead of inheriting from ApplicationJob
  include Camunda::ExternalTaskJob
  # queue_as :camunda

  # Customize if needed for your Camunda background task instances
end
