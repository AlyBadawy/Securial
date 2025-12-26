require_relative "lib/securial/version"

Gem::Specification.new do |spec|
  spec.name                           = "securial"
  spec.version                        = Securial::VERSION.dup
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

  spec.metadata["homepage_uri"]       = spec.homepage
  spec.metadata["release_date"]       = Time.now.utc.strftime('%Y-%m-%d')
  spec.metadata["allowed_push_host"]  = "https://rubygems.org"
  spec.metadata["source_code_uri"]    = "https://github.com/AlyBadawy/Securial"
  spec.metadata["documentation_uri"]  = "https://alybadawy.github.io/Securial/_index.html"
  spec.metadata["changelog_uri"]      = "https://github.com/AlyBadawy/Securial/blob/main/CHANGELOG.md"
  spec.metadata["wiki_uri"]           = "https://github.com/AlyBadawy/Securial/wiki"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md", ".yardopts"]
  end

  spec.required_ruby_version                        = ">= 4.0.0"

  spec.add_runtime_dependency         "rails",        "~> 8.1"

  spec.add_dependency                 "bcrypt",       "~> 3.1"
  spec.add_dependency                 "jbuilder",     "~> 2.13"
  spec.add_dependency                 "jwt",          ">= 3.0", "< 3.2"
  spec.add_dependency                 "rack-attack",  "~> 6.7"

  spec.post_install_message = <<~MESSAGE
    \033[36m
     ▗▄▄▖▗▄▄▄▖ ▗▄▄▖▗▖ ▗▖▗▄▄▖ ▗▄▄▄▖ ▗▄▖ ▗▖
    ▐▌   ▐▌   ▐▌   ▐▌ ▐▌▐▌ ▐▌  █  ▐▌ ▐▌▐▌
     ▝▀▚▖▐▛▀▀▘▐▌   ▐▌ ▐▌▐▛▀▚▖  █  ▐▛▀▜▌▐▌
    ▗▄▄▞▘▐▙▄▄▖▝▚▄▄▖▝▚▄▞▘▐▌ ▐▌▗▄█▄▖▐▌ ▐▌▐▙▄▄▖
    \033[0m

    \033[32mThank you for installing Securial!\033[0m

    \033[37mSecurial is a mountable Rails engine that provides robust, extensible
    authentication and access control for Rails applications. It supports JWT,
    API tokens, session-based auth, and is designed for easy integration with
    modern web and mobile apps.\033[0m

    \033[33mUsage:\033[0m
      \033[36msecurial new APP_NAME [rails_options...]\033[0m    # Create a new Rails app with Securial pre-installed
      \033[36msecurial -v, --version\033[0m                      # Show the Securial gem version
      \033[36msecurial -h, --help\033[0m                         # Show this help message

    \033[33mExample:\033[0m
      \033[32msecurial new myapp --api --database=postgresql -T\033[0m

    \033[33mMore Info:\033[0m
      \033[37mreview the [changelog] and [WIKI] for more info on the latest
      changes and how to use this gem/engine:\033[0m
        \033[34m[Changelog]:  https://github.com/AlyBadawy/Securial/blob/main/CHANGELOG.md\033[0m
        \033[34m[WIKI]:       https://github.com/AlyBadawy/Securial/wiki\033[0m
    \033[90m---\033[0m
  MESSAGE
end
