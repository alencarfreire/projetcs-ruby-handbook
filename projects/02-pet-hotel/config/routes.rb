Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Quem está no hotel agora (stays checked_in). Sem login, o controller manda para /login.
  root "occupancy#index"

  get  "/signup", to: "users#new"
  post "/signup", to: "users#create"
  get  "/login",  to: "sessions#new"
  post "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  resources :owners
  resources :pets
  resources :stays do
    member do
      post :check_in
      post :check_out
    end
  end
end
