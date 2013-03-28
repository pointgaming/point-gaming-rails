require 'resque/server'

Pointgaming::Application.routes.draw do
  resources :matches, only: [:edit, :update] do
    member do
      put 'start'
      put 'cancel'
      put 'finalize'
    end
    resources :bets, only: [:new, :show, :create, :update, :destroy]
  end
  resources :friend_requests
  resources :leagues
  resources :tournaments
  resources :s, controller: 'streams', as: 'streams' do
    resources :matches, only: [:index, :new, :show, :create, :destroy]
  end
  resources :game_rooms do
    resources :matches, only: [:index, :new, :show, :create, :destroy]
  end
  resources :t, controller: 'teams', as: 'teams', except: [:edit, :update] do
    collection do
      put 'change_active'
    end
    resources :members, controller: 'team_members'
  end
  resources :store
  resources :faq
  resources :settings
  resources :bet_history
  resources :subscriptions, only: [:index, :new, :create]
  resources :user_streams do
    resources :collaborators, only: [:index, :new, :create, :destroy]
    member do
      put 'change_owner'
      put 'start'
      put 'stop'
    end
  end

  resources :games

  namespace :admin do
    root :to => "dashboard#index"
    resources :groups do
      resources :users, controller: 'group_users'
    end
    resources :news
  end

  namespace :api do
    namespace :v1 do
      resources :coins
      resources :games, only: [:index]
      resources :sessions
      resources :friends
      resources :friend_requests
      resources :ignores
      resources :matches, only: [:update] do
        member do
          put 'start'
          put 'cancel'
          put 'finalize'
        end
        resources :bets, only: [:new, :show, :create, :update, :destroy]
      end
      resources :streams, only: [] do
        resources :matches, only: [:index, :new, :show, :create, :destroy]
      end
      resources :game_rooms, only: [:index, :show, :create, :update] do
        resources :matches, only: [:index, :new, :show, :create, :destroy]
      end
    end
  end

  root :to => 'home#index'

  get "/search", :to => "search#index"
  get "/search/playable", :to => "search#playable"

  get "/users/search", :to => "users#search"

  get "/u/:user_id/configs/new", :to => "user_configs#new", as: 'new_user_config'
  post "/u/:user_id/configs", :to => "user_configs#create", as: 'user_configs'
  delete "/u/:user_id/configs/:id(.:format)", :to => "user_configs#destroy", as: 'user_config'

  get "/u/:user_id/avatar/edit", :to => "user_avatar#edit", as: 'edit_user_avatar'
  put "/u/:user_id/avatar", :to => "user_avatar#update", as: 'user_avatar'

  get "/u/:user_id/profile/edit", :to => "user_profiles#edit", as: 'edit_user_profile'
  get "/u/:user_id/profile", :to => "user_profiles#show", as: 'user'
  put "/u/:user_id/profile", :to => "user_profiles#update"
  get '/u/subregion_options' => 'user_profiles#subregion_options'

  devise_for :users

  authenticate :user, lambda {|u| u.admin? } do
    mount Resque::Server.new, :at => "/resque"
  end

end
