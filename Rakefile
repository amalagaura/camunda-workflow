begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end
require 'rdoc/task'
require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require 'yard'

# Runs Rubocop with rake rubocop
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
  t.options = ['-a']
end

# Run yard using rake yard
YARD::Rake::YardocTask.new

# Run rspec with rake spec
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = [].tap do |a|
    a.push('--color')
    a.push('--format progress')
  end.join(' ')
end
# Run rdoc with rake rdoc
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Camunda Workflow gem with RSpec'
  rdoc.options << '--line-numbers'
  # rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
# By default, `rake` will run specs, yard, and rubocop -a
task default: %w[spec yard rubocop]
