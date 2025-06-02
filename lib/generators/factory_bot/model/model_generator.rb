require "rails/generators"
require "rails/generators/named_base"

module FactoryBot
  module Generators
    class ModelGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"

      def create_factory_file
        template "factory.erb", File.join("lib/securial/factories/securial", "#{file_name.pluralize}.rb")
      end

      # Helper method accessible in the template
      def securial_attribute_defaults
        {
          string: '"MyString"',
          text: '"MyText"',
          integer: "1",
          float: "1.5",
          decimal: '"9.99"',
          datetime: "Time.zone.now",
          time: "Time.zone.now",
          date: "Time.zone.now",
          boolean: "false",
        }
      end
    end
  end
end
