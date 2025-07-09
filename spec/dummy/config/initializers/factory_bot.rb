if defined?(FactoryBot)
  FactoryBot.definition_file_paths << Rails.root.join("..", "..", "lib", "securial", "factories")
  require_relative "../../../../lib/generators/factory_bot/model/model_generator"
end
