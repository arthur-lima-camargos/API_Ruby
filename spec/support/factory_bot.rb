# Allows calling `create(:user)` / `build(:user)` directly in specs,
# without the `FactoryBot.` prefix.
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
