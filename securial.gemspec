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

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.required_ruby_version          = ">= 3.4.0"

  spec.add_runtime_dependency         "rails", "~> 8.0"

  spec.add_dependency                 "bcrypt", "~> 3.1"
  spec.add_dependency                 "jbuilder", "~> 2.11"
  spec.add_dependency                 "jwt", "~> 2.10"

  spec.post_install_message = %q(
    ---
    [SECURIAL] Thank you for installing Securial!

    Securial is a mountable Rails engine that provides robust, extensible
    authentication and access control for Rails applications. It supports JWT,
    API tokens, session-based auth, and is designed for easy integration with
    modern web and mobile apps.

    Usage:
      securial new APP_NAME [rails_options...]    # Create a new Rails app with Securial pre-installed
      securial -v, --version                      # Show the Securial gem version
      securial -h, --help                         # Show this help message

    Example:
      securial new myapp --api --database=postgresql -T

    More Info:
      review the [changelog] and [WIKI] for more info on the latest
      changes and how to use this gem/engine:
        [changelog]:  https://github.com/AlyBadawy/Securial/blob/main/CHANGELOG.md
        [WIKI]:       https://github.com/AlyBadawy/Securial/wiki
    ---
  )
end
