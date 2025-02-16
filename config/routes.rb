require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"

  resources :carts, only: [:show] do
    collection do
      post :add_items
    end
  end
end
