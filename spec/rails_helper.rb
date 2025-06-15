require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../dummy/config/environment", __FILE__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"

Securial::Engine.root.glob("spec/support/**/*.rb").sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.include RequestSpecHelper, type: :request
  config.include GeneratorSpec::TestCase, type: :generator
  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers

  config.include Securial::Engine.routes.url_helpers

  config.filter_rails_from_backtrace!
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = true
  Rails.application.routes.default_url_options[:host] = "test.host"


  ActiveRecord::Migration.suppress_messages do
    ActiveRecord::Schema.define do
      create_table :test_users, force: true do |t|
        t.string :email_address
        t.string :password_digest
        t.string :reset_password_token
        t.datetime :reset_password_token_created_at
        t.datetime :password_changed_at
        t.timestamps
      end
    end
  end

  FactoryBot.definition_file_paths = [
    File.expand_path("factories", __dir__),
  ]
  FactoryBot.find_definitions

  Shoulda::Matchers.configure do |shoulda_config|
    shoulda_config.integrate do |with|
      with.test_framework :rspec
      with.library :rails
    end
  end
end
