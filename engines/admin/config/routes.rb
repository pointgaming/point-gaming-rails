PointGamingRails::Application.routes.draw do
  namespace :admin do
    root to: "dashboard#index"
    resources :tournaments do
      member do
        get "payment"
        put "approve"
      end
    end
    resources :disputes, only: [:index, :show, :edit, :update] do
      resources :messages, controller: "dispute_messages", only: [:new, :create]
      member do
        put "cancel"
      end
    end
    resources :groups do
      resources :users, controller: "group_users"
    end
    resources :game_types
    resources :subscription_features
    resources :subscription_types
    resources :reports, only: [:index] do
      collection do
        get "point_audit"
      end
    end
    resources :news
  end
end
