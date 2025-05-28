# This file is copied to spec/ when you run 'rails generate rspec:install'
require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../dummy/config/environment", __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

require "database_cleaner"

Rails.root.glob("spec/support/**/*.rb").each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.fixture_paths = [Rails.root.join("spec/fixtures")]

  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!

  config.before(:suite) { DatabaseCleaner.clean_with(:truncation) }
  config.before(:each) { DatabaseCleaner.strategy = :transaction }
  config.before(:each, :js) { DatabaseCleaner.strategy = :truncation }
  config.before(:each) { DatabaseCleaner.start }
  config.after(:each) { DatabaseCleaner.clean }
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include GeneratorSpec::TestCase, type: :generator
  config.include ActiveSupport::Testing::TimeHelpers

  config.before(:each) do
    @signed_in_user = create(:securial_user)
    @signed_in_session = create(:securial_session, user: @signed_in_user)
    @valid_token = Securial::Sessions::SessionEncoder.encode(@signed_in_session)
    @valid_headers = { "Authorization" => "Bearer #{@valid_token}", "User-Agent" => "Ruby/RSpec" }
    @invalid_headers = { "Authorization" => "Bearer bad_token" }
  end

  FactoryBot.definition_file_paths = [
    File.expand_path("factories", __dir__)
  ]
  FactoryBot.find_definitions

  Shoulda::Matchers.configure do |conf|
    conf.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end

  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define do
      create_table :test_users, force: true do |t|
        t.string :email_address
        t.string :password_digest
        t.string :reset_password_token
        t.datetime :reset_password_token_created_at
        t.timestamps
      end
    end
  end
end
