require "rails/generators"
require "rake"

module Securial
  module Generators
    module Install
      class ViewsGenerator < Rails::Generators::Base
        source_root Securial::Engine.root.join("app", "views", "securial").to_s
        desc "Copies Securial model-related views to your application for customization."

        def copy_model_views
          Dir.glob(File.join(self.class.source_root, "**/*")).each do |path|
            relative_path = Pathname.new(path).relative_path_from(Pathname.new(self.class.source_root))

            if File.directory?(path)
              empty_directory "app/views/securial/#{relative_path}"
            else
              copy_file path, "app/views/securial/#{relative_path}"
            end
          end
        end
      end
    end
  end
end
