Rails.application.routes.draw do
  get "/", to: "application#index", as: "root"
  get "/new", to: "application#new", as: "new_game"
  post "/move", to: "application#move", as: "move"
end
