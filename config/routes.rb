require 'resque/server'
require 'resque_scheduler'
require 'resque_scheduler/server'

PointGamingRails::Application.routes.draw do
  resources :matches, only: [:show, :edit, :update] do
    member do
      put 'start'
      put 'cancel'
      put 'finalize'
    end
    resources :bets, only: [:new, :show, :create, :update, :destroy]
    resources :disputes, only: [:new, :create]
  end
  resources :friend_requests
  resources :friends
  resources :blocked_users, only: [:index, :create, :destroy]
  resources :disputes, only: [:index, :show] do
    resources :messages, controller: 'dispute_messages', only: [:new, :create]
    member do
      put 'cancel'
    end
  end
  resources :leagues
  resources :tournaments, only: [:index, :show] do
    resources :sponsors, controller: 'tournament_sponsors', except: [:index, :show]
  end
  resources :user_tournaments do
    resources :collaborators, controller: 'tournament_collaborators', only: [:create, :destroy]
    resources :invites, controller: 'tournament_invites', only: [:create, :destroy]
    resources :payments, controller: 'tournament_payments', only: [:new, :create]
    member do
      get 'prize_pool'
      get 'status'
      get 'users'
    end
  end
  resources :streams, controller: 'streams', as: 'streams', only: [:index, :create]
  resources :s, controller: 'streams', as: 'streams', except: [:index, :create, :edit, :update] do
    resources :matches, only: [:index, :new, :show, :create, :destroy]
    member do
      get 'embedded_content'
    end
  end
  resources :game_rooms do
    resources :matches, only: [:index, :new, :show, :create, :destroy]
  end
  resources :teams, controller: 'teams', as: 'teams', only: [:index, :create]
  resources :t, controller: 'teams', as: 'teams', except: [:index, :create] do
    collection do
      put 'change_active'
    end
    resources :members, controller: 'team_members'
    resources :sponsors, controller: 'team_sponsors', except: [:index, :show]
  end
  resources :store
  resources :faq
  resources :settings
  resources :billing, except: [:index]
  resources :bet_history
  resources :orders, only: [:show]
  resources :subscriptions, only: [:index, :new, :create, :edit, :update] do
    collection do
      get 'current'
    end
  end
  resources :user_streams do
    resources :collaborators, only: [:index, :new, :create, :destroy]
    member do
      put 'change_owner'
      put 'start'
      put 'stop'
    end
  end

  resources :games

  namespace :api do
    namespace :v1 do
      resources :users do
        member do
          put 'increment_points'
        end
      end
      resources :coins
      resources :games, only: [:index]
      resources :sessions
      resources :friends
      resources :friend_requests
      resources :matches, only: [:update] do
        member do
          put 'start'
          put 'cancel'
          put 'finalize'
        end
        resources :bets, only: [:new, :show, :create, :update, :destroy]
      end
      resources :disputes, only: [:show] do
        member do
          put 'incrementAdminViewerCount'
          put 'incrementUserViewerCount'
        end
      end
      resources :streams, only: [:show] do
        member do
          put 'incrementViewerCount'
        end
        resources :matches, only: [:index, :new, :show, :create, :destroy]
      end
      resources :game_rooms, only: [:show, :destroy] do
        member do
          put 'join'
          put 'leave'
        end
      end
    end
  end

  get '/desktop_client/version', to: 'site#desktop_version'
  get '/leaderboard', to: 'site#leaderboard'
  get '/game_type_options', to: 'site#game_type_options'

  resources :news, only: [:show] do
    resources :comments, except: [:index], controller: 'news_comments'
  end

  root :to => 'home#index'

  get "/search", :to => "search#index"
  get "/search/playable", :to => "search#playable"
  get "/search/store", :to => "search#store"

  get "/users/search", :to => "users#search"

  resources :demos, only: [:index, :show]

  resources :users, path: "/u", only: [] do
    resources :demos, only: [:new, :create, :destroy]
    resources :configs, only: [:new, :create, :destroy]
    resources :sponsors, controller: 'user_sponsors', except: [:index, :show]
    resources :friends, controller: 'user_friends', only: [:index]
  end

  get "/u/:user_id/avatar/edit", :to => "user_avatar#edit", as: 'edit_user_avatar'
  put "/u/:user_id/avatar", :to => "user_avatar#update", as: 'user_avatar'

  get "/u/:user_id/profile/edit", :to => "user_profiles#edit", as: 'edit_user_profile'
  get "/u/:user_id", :to => "user_profiles#show", as: 'user'
  put "/u/:user_id", :to => "user_profiles#update"
  get "/u/:user_id/profile", :to => "user_profiles#show", as: 'user_profile'
  get '/users/subregion_options' => 'user_profiles#subregion_options'

  devise_for :users

  authenticate :user, lambda {|u| u.admin? } do
    mount Resque::Server.new, :at => "/resque"
  end

end
