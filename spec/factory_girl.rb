RSpec.configure do |config|

  # include this module if you don't want to have to type FactoryBot for each build, create, etc:
  config.include FactoryBot::Syntax::Methods

  config.before :suite do
    begin
      FactoryBot.reload # make sure factories aren't cached by Spring
      DatabaseCleaner.start
        #FactoryBot.lint # make sure all factories are #valid?
    ensure
      DatabaseCleaner.clean
    end
  end
end
