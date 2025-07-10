# @title Securial Command Line Interface
#
# Command line interface for the Securial framework.
#
# This file implements the CLI tool for Securial, providing command-line utilities
# for creating new Rails applications with Securial pre-installed. It handles
# command parsing, option flags, and orchestrates the application setup process.
#
# @example Creating a new Rails application with Securial
#   # Create a basic Securial application
#   $ securial new myapp
#
#   # Create an API-only Securial application with PostgreSQL
#   $ securial new myapi --api --database=postgresql
#
require "optparse"
require "yaml"
require "erb"

# rubocop:disable Rails/Exit, Rails/Output

module Securial
  # Command-line interface for the Securial gem.
  #
  # This class provides the command-line functionality for Securial, enabling users
  # to create new Rails applications with Securial pre-installed and configured.
  # It handles command parsing, flag processing, and orchestrates the setup of
  # new applications.
  #
  class CLI
    # Entry point for the CLI application.
    #
    # Creates a new CLI instance and delegates to its start method.
    #
    # @param argv [Array<String>] command line arguments
    # @return [Integer] exit status code (0 for success, non-zero for errors)
    #
    def self.start(argv)
      new.start(argv)
    end

    # Processes command line arguments and executes the appropriate action.
    #
    # This method handles both option flags (like --version) and commands
    # (like 'new'), delegating to specialized handlers and returning
    # the appropriate exit code.
    #
    # @param argv [Array<String>] command line arguments
    # @return [Integer] exit status code (0 for success, non-zero for errors)
    #
    def start(argv)
      # Process options and exit if a flag was handled
      result = handle_flags(argv)
      exit(result) if result

      # Otherwise handle commands
      exit(handle_commands(argv))
    end

    private

    # Processes option flags from the command line arguments.
    #
    # Parses options like --version and --help, executing their actions
    # if present and removing them from the argument list.
    #
    # @param argv [Array<String>] command line arguments
    # @return [nil, Integer] nil to continue processing, or exit code
    #
    def handle_flags(argv)
      parser = create_option_parser

      begin
        parser.order!(argv)
        nil # Continue to command handling
      rescue OptionParser::InvalidOption => e
        warn "ERROR: Illegal option(s): #{e.args.join(' ')}"
        puts parser
        1
      end
    end

    # Processes commands from the command line arguments.
    #
    # Identifies the command (e.g., 'new') and delegates to the appropriate
    # handler method for that command.
    #
    # @param argv [Array<String>] command line arguments
    # @return [Integer] exit status code (0 for success, non-zero for errors)
    #
    def handle_commands(argv)
      cmd = argv.shift

      case cmd
      when "new"
        handle_new_command(argv)
      else
        puts create_option_parser
        1
      end
    end

    # Handles the 'new' command for creating Rails applications.
    #
    # Validates that an application name is provided, then delegates to
    # securial_new to create the application with Securial.
    #
    # @param argv [Array<String>] remaining command line arguments
    # @return [Integer] exit status code (0 for success, non-zero for errors)
    #
    def handle_new_command(argv)
      app_name = argv.shift

      if app_name.nil?
        puts "ERROR: Please provide an app name."
        puts create_option_parser
        return 1
      end

      securial_new(app_name, argv)
      0
    end

    # Creates and configures the option parser.
    #
    # Sets up the command-line options and their handlers.
    #
    # @return [OptionParser] configured option parser instance
    #
    def create_option_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: securial [options] <command> [command options]\n\n"

        opts.separator ""
        opts.separator "Commands:"
        opts.separator "    new APP_NAME [rails_options...]    # Create a new Rails app with Securial pre-installed"
        opts.separator ""
        opts.separator "Options:"

        opts.on("-v", "--version", "Show Securial version") do
          show_version
          exit(0)
        end

        opts.on("-h", "--help", "Show this help message") do
          puts opts
          exit(0)
        end
      end
    end

    # Displays the current Securial version.
    #
    # @return [void]
    #
    def show_version
      require "securial/version"
      puts "Securial v#{Securial::VERSION}"
    rescue LoadError
      puts "Securial version information not available."
    end

    # Creates a new Rails application with Securial pre-installed.
    #
    # Orchestrates the process of creating a Rails application, adding the
    # Securial gem, installing dependencies, and configuring the application.
    #
    # @param app_name [String] name of the Rails application to create
    # @param rails_options [Array<String>] options to pass to 'rails new'
    # @return [void]
    #
    def securial_new(app_name, rails_options)
      puts "🏗️  Creating new Rails app: #{app_name}"

      create_rails_app(app_name, rails_options)
      update_database_yml_host(app_name)
      add_securial_gem(app_name)
      install_gems(app_name)
      install_securial(app_name)
      mount_securial_engine(app_name)
      print_final_instructions(app_name)
    end

    # Creates a new Rails application.
    #
    # @param app_name [String] name of the Rails application to create
    # @param rails_options [Array<String>] options to pass to 'rails new'
    # @return [Integer] command exit status
    #
    def create_rails_app(app_name, rails_options)
      rails_command = ["rails", "new", app_name, *rails_options]
      run(rails_command)
    end

    # Adds DB_HOST env. variable to as default host in `database.yml`.
    #
    # @param app_name [String] name of the Rails application
    # @return [void]
    #
    def update_database_yml_host(app_name)
      db_config_path = File.join(app_name, "config", "database.yml")
      raw = File.read(db_config_path)
      rendered = ERB.new(raw).result
      config = YAML.safe_load(rendered, aliases: true) || {}

      config["default"] ||= {}
      return if config["default"]["adapter"].blank?
      return unless ["mysql2", "postgresql"].include?(config["default"]["adapter"])
      config["default"]["host"] = "<%= ENV.fetch(\"RAILS_DATABASE_HOST\", \"localhost\") %>"
      config["default"]["username"] = "<%= ENV.fetch(\"DB_USERNAME\") { \"postgres\" } %>"
      config["default"]["password"] = "<%= ENV.fetch(\"DB_PASSWORD\") { \"postgres\" } %>"

      # Dump YAML manually to preserve formatting
      yaml = config.to_yaml.gsub(/['"](<%= .*? %>)['"]/, '\1') # Unquote the ERB
      File.write(db_config_path, yaml)
    end

    # Adds the Securial gem to the application's Gemfile.
    #
    # @param app_name [String] name of the Rails application
    # @return [void]
    #
    def add_securial_gem(app_name)
      puts "📦  Adding Securial gem to Gemfile"
      gemfile_path = File.join(app_name, "Gemfile")
      File.open(gemfile_path, "a") { |f| f.puts "\ngem 'securial'" }
    end

    # Installs gems for the application using Bundler.
    #
    # @param app_name [String] name of the Rails application
    # @return [Integer] command exit status
    #
    def install_gems(app_name)
      run("bundle install", chdir: app_name)
    end

    # Installs and configures Securial in the application.
    #
    # @param app_name [String] name of the Rails application
    # @return [Integer] command exit status
    #
    def install_securial(app_name)
      puts "🔧  Installing Securial"
      run("bin/rails generate securial:install", chdir: app_name)
      run("bin/rails db:migrate", chdir: app_name)
    end

    # Mounts the Securial engine in the application's routes.
    #
    # @param app_name [String] name of the Rails application
    # @return [void]
    #
    def mount_securial_engine(app_name)
      puts "🔗  Mounting Securial engine in routes"
      routes_path = File.join(app_name, "config/routes.rb")
      routes = File.read(routes_path)
      updated = routes.sub("Rails.application.routes.draw do") do |match|
        "#{match}\n  mount Securial::Engine => '/securial'"
      end
      File.write(routes_path, updated)
    end

    # Prints final setup instructions after successful installation.
    #
    # @param app_name [String] name of the Rails application
    # @return [void]
    #
    def print_final_instructions(app_name)
      puts <<~INSTRUCTIONS
        🎉  Securial has been successfully installed in your Rails app!
        ✅  Your app is ready at: ./#{app_name}

        ➡️  Next steps:
            cd #{app_name}
        ⚙️  Optional: Configure Securial in config/initializers/securial.rb
            rails server
      INSTRUCTIONS
    end

    # Runs a system command with optional directory change.
    #
    # Executes the provided command, optionally in a different directory,
    # and handles success/failure conditions.
    #
    # @param command [String, Array<String>] command to run
    # @param chdir [String, nil] directory to change to before running command
    # @return [Integer] command exit status code (0 for success)
    # @raise [SystemExit] if the command fails
    #
    def run(command, chdir: nil)
      puts "→ #{command.inspect}"
      result =
        if chdir
          Dir.chdir(chdir) { system(*command) }
        else
          system(*command)
        end

      unless result
        abort("❌ Command failed: #{command}")
      end
      0
    end
  end
end

# rubocop:enable Rails/Exit, Rails/Output
