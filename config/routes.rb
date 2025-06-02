Securial::Engine.routes.draw do
  defaults format: :json do
    get "/status", to: "status#show", as: :status
  end
end
