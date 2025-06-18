# rubocop:disable Rails/Output
def show_help
  puts <<~HELP
    Securial CLI

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
      review the [Changelog] and [WIKI] for more info on the latest
      changes and how to use this gem/engine:
        [Changelog]:  https://github.com/AlyBadawy/Securial/blob/main/CHANGELOG.md
        [WIKI]:       https://github.com/AlyBadawy/Securial/wiki

  HELP
end