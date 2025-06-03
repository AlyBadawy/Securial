Securial::Engine.routes.draw do
  defaults format: :json do
    get "/status", to: "status#show", as: :status

    scope Securial.protected_namespace do
      resources :roles
    end
  end
end
