require_relative "lib/securial/version"

Gem::Specification.new do |spec|
  spec.name                           = "securial"
  spec.version                        = Securial::VERSION
  spec.authors                        = ["Aly Badawy"]
  spec.email                          = ["1198568+AlyBadawy@users.noreply.github.com"]
  spec.homepage                       = "https://github.com/AlyBadawy/Securial/wiki"
  spec.summary                        = "Authentication and access control Rails engine for your API."
  spec.description                    = "Securial is a mountable Rails engine that provides robust, extensible"
  spec.description                   += " authentication and access control for Rails applications. It supports JWT,"
  spec.description                   += " API tokens, session-based auth, and is designed for easy integration with"
  spec.description                   += " modern web and mobile apps."
  spec.license                        = "MIT"
  spec.executables                    = ["securial"]

  spec.date                           = Time.now.utc.strftime('%Y-%m-%d')
  spec.metadata['release_date']       = Time.now.utc.strftime('%Y-%m-%d')

  spec.metadata["allowed_push_host"]  = "https://rubygems.org"
  spec.metadata["homepage_uri"]       = spec.homepage
  spec.metadata["source_code_uri"]    = "https://github.com/AlyBadawy/Securial"
  spec.metadata["changelog_uri"]      = "https://github.com/AlyBadawy/Securial/blob/main/CHANGELOG.md"

  spec.files                           = Dir.glob("{app,config,db,lib}/**/*") + %w[MIT-LICENSE Rakefile README.md]

  spec.required_ruby_version          = ">= 3.4.1"

  spec.add_runtime_dependency         "rails", "~> 8.0"

  spec.add_dependency                 "bcrypt", "~> 3.1"
  spec.add_dependency                 "jbuilder", "~> 2.11"
  spec.add_dependency                 "jwt", "~> 2.10"
  spec.add_dependency                 "ostruct", "~> 0.6"

  spec.add_development_dependency     "capybara", "~> 3.40"
  spec.add_development_dependency     "coveralls-lcov", "~> 1.7"
  spec.add_development_dependency     "database_cleaner", "~> 2.1"
  spec.add_development_dependency     "factory_bot_rails", "~> 6.4"
  spec.add_development_dependency     "faker", "~> 3.5"
  spec.add_development_dependency     "generator_spec", "~> 0.10"
  spec.add_development_dependency     "overcommit", "~> 0.67"
  spec.add_development_dependency     "rubocop", "~> 1.75"
  spec.add_development_dependency     "rubocop-config-prettier", "~> 0.1.13"
  spec.add_development_dependency     "rubocop-performance", "~> 1.25"
  spec.add_development_dependency     "rubocop-rails", "~> 2.32"
  spec.add_development_dependency     "rubocop-rails-omakase", "~> 1.1"
  spec.add_development_dependency     "rubocop-rspec", "~> 3.6"
  spec.add_development_dependency     "rspec-rails", '~> 7.1'
  spec.add_development_dependency     "shoulda-matchers", "~> 6.5"
  spec.add_development_dependency     "simplecov", "~> 0.22"
  spec.add_development_dependency     "simplecov-lcov", "~> 0.8.0"
end
