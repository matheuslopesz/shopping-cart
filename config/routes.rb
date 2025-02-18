require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"

  resources :carts, only: %i[show create] do
    collection do
      patch :add_item, to: 'carts#update'
      delete :remove_item, to: 'carts#remove_item'
    end
  end
end
