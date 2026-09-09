Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post   "/signup", to: "users#create"
      post   "/login",  to: "sessions#create"
      delete "/logout", to: "sessions#destroy"

      get "/occupancy", to: "occupancy#index"

      resources :owners
      resources :pets
      resources :stays do
        member do
          post :check_in
          post :check_out
        end
      end
    end
  end
end
