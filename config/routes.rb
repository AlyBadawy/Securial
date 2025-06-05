Rails.application.routes.default_url_options[:host] = "http://localhost:3000"

Securial::Engine.routes.draw do
  default_url_options host: "example.com"

  defaults format: :json do
    get "/status", to: "status#show", as: :status

    scope Securial.protected_namespace do
      resources :roles
      resources :users
      namespace :role_assignments, as: "role_assignments" do
        post "assign", action: :create, as: "assign"
        delete "revoke", action: :destroy, as: "revoke"
      end
    end
  end
end
