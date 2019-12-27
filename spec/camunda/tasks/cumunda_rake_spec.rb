require 'rake'

describe Rake do
  let(:camunda_run) { described_class.application.invoke_task("camunda:run") }
  let(:camunda_test) { described_class.application.invoke_task("camunda:test") }

  before do
    described_class.application.rake_require('tasks/camunda')
    Rake::Task.define_task(:environment)
  end

  it 'rake camunda:task' do
    expect { camunda_run }.not_to raise_error
    expect { camunda_test }.not_to raise_error
  end
end
