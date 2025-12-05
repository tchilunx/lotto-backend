Rails.application.routes.draw do
  root "home#index"
  get "dashboard" => "dashboard#index"

  devise_for :clients

  namespace :api do
    namespace :v1 do
      devise_scope :client do
        post "login", to: "clients/sessions#create"
        delete "logout", to: "clients/sessions#destroy"
        post "register", to: "clients/registrations#create"
      end

      namespace :clients do
        get "wallet", to: "clients#wallet"
      end

      resources :wallets, only: [] do
        collection do
          get :show
          get :balance
          get :operations
        end
      end

      resources :kyc_requests, only: [ :create ] do
        collection do
          get :show_by_client
        end
      end

      resources :topups, only: [ :create, :index ] do
        collection do
          put :confirm
        end
      end

      resources :withdrawals, only: [ :create, :index ] do
        collection do
          put :confirm
        end
      end

      resources :lotto_bets, only: [ :create, :index, :show ]
      resources :lotto_draws, only: [ :index, :show, :create ] do
        collection do
          get :latest
        end
        member do
          get :bets
        end
      end
      resources :lotto_wins, only: [ :index ]
    end
  end

  # Sidekiq dashboard
  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"
end
