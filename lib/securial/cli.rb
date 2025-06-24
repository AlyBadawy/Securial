require "optparse"

# rubocop:disable Rails/Exit, Rails/Output

module Securial
  class CLI
    def self.start(argv)
      new.start(argv)
    end

    def start(argv)
      # Process options and exit if a flag was handled
      result = handle_flags(argv)
      exit(result) if result

      # Otherwise handle commands
      exit(handle_commands(argv))
    end

    private

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

    def show_version
      require "securial/version"
      puts "Securial v#{Securial::VERSION}"
    rescue LoadError
      puts "Securial version information not available."
    end

    def securial_new(app_name, rails_options)
      puts "🏗️  Creating new Rails app: #{app_name}"

      create_rails_app(app_name, rails_options)
      add_securial_gem(app_name)
      install_gems(app_name)
      install_securial(app_name)
      mount_securial_engine(app_name)
      print_final_instructions(app_name)
    end

    def create_rails_app(app_name, rails_options)
      rails_command = ["rails", "new", app_name, *rails_options]
      run(rails_command)
    end

    def add_securial_gem(app_name)
      puts "📦  Adding Securial gem to Gemfile"
      gemfile_path = File.join(app_name, "Gemfile")
      File.open(gemfile_path, "a") { |f| f.puts "\ngem 'securial'" }
    end

    def install_gems(app_name)
      run("bundle install", chdir: app_name)
    end

    def install_securial(app_name)
      puts "🔧  Installing Securial"
      run("bin/rails generate securial:install", chdir: app_name)
      run("bin/rails db:migrate", chdir: app_name)
    end

    def mount_securial_engine(app_name)
      puts "🔗  Mounting Securial engine in routes"
      routes_path = File.join(app_name, "config/routes.rb")
      routes = File.read(routes_path)
      updated = routes.sub("Rails.application.routes.draw do") do |match|
        "#{match}\n  mount Securial::Engine => '/securial'"
      end
      File.write(routes_path, updated)
    end

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
