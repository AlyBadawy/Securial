# rubocop:disable Rails/Output
require_relative "run"

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
  rails_command = ["rails", "new", app_name, *rails_options].join(" ")
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
  puts "🎉  Securial has been successfully installed in your Rails app!"
  puts "✅  Your app is ready at: ./#{app_name}"
  puts ""
  puts "➡️  Next steps:"
  puts "    cd #{app_name}"
  puts "⚙️  Optional: Configure Securial in config/initializers/securial.rb"
  puts "    rails server"
end
