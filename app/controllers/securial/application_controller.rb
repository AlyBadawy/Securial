module Securial
  class ApplicationController < ActionController::API
    prepend_view_path Securial::Engine.root.join("app", "views")
  end
end
