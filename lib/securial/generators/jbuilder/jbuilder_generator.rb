module Securial
  module Generators
    class JbuilderGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      def create_view_files
        create_resource_file
        create_index_file
        create_show_file
      end

      private

      def attributes_names
        attributes.map(&:name)
      end

      def create_resource_file
        @resource_path_name = File.join(view_path, "_#{singular_table_name}.json.jbuilder")
        say_status(status_behavior, "  #{@resource_path_name}", status_color) unless Rails.env.test?
        template "_resource.json.erb", @resource_path_name, verbose: false
      end

      def create_index_file
        @index_path_name = File.join(view_path, "index.json.jbuilder")
        say_status(status_behavior, "  #{@index_path_name}", status_color) unless Rails.env.test?
        template "index.json.erb", @index_path_name, verbose: false
      end

      def create_show_file
        @show_path_name = File.join(view_path, "show.json.jbuilder")
        say_status(status_behavior, "  #{@show_path_name}", status_color) unless Rails.env.test?
        template "show.json.erb", @show_path_name, verbose: false
      end

      def view_path
        base_path = Rails.env.test? ? Rails.root.join("tmp/app/views/securial").to_s : "app/views/securial"
        @view_path ||= File.join(base_path, name.pluralize.downcase)
      end

      def status_behavior
        behavior == :invoke ? :create : :remove
      end

      def status_color
        behavior == :invoke ? :green : :red
      end
    end
  end
end
