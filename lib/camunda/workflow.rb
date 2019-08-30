require_relative '../camunda.rb'
require_relative './model.rb'
Dir[File.join(__dir__, '*.rb')].each(&method(:require))
