Gem::Specification.new do |spec|
  spec.name          = 'camunda-workflow'
  spec.version       = '0.1'
  spec.date          = '2019-08-30'
  spec.summary       = "Opinionated Ruby integration with Camunda"
  spec.description   = "Integrate Camunda with Ruby via its REST api by expecting a Ruby class for each external task."
  spec.authors       = ["Ankur Sethi"]
  spec.email         = 'ankur.sethi@uscis.dhs.gov'
  spec.files         = Dir["*.{md,txt}", "{app,config,lib}/**/*"]
  spec.require_paths = ["lib"]
  spec.homepage      = 'https://rubygems.org/gems/camunda-workflow'
  spec.license       = 'MIT'
  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency 'her', '~> 1.1'
  # We only need .camelcase and .underscore from activesupport
  spec.add_dependency 'activesupport', '>= 3.2.0'
end
