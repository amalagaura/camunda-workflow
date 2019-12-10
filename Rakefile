begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb'] # optional
  t.options = ['--any', '--extra', '--opts'] # optional
  t.stats_options = ['--list-undoc']         # optional
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb'] # optional
  t.options = ['--any', '--extra', '--opts'] # optional
  t.stats_options = ['--list-undoc']         # optional
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/**/*.rb'] # optional
  t.options = ['--any', '--extra', '--opts'] # optional
  t.stats_options = ['--list-undoc']         # optional
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Camunda Workflow gem with RSpec'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("spec/dummy/Rakefile", __dir__)

load 'rails/tasks/engine.rake'
load 'rails/tasks/statistics.rake'

Bundler::GemHelper.install_tasks
