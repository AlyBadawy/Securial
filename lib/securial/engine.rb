module Securial
  class Engine < ::Rails::Engine
    isolate_namespace Securial
    config.generators.api_only = true
  end
end
