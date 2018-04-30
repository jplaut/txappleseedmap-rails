Rails.application.routes.draw do
  root to: 'home#index'

  namespace :api do
    namespace :v1 do
      resources :districts, only: [:index]
      resources :statistics, only: [:index]
    end
  end
end
