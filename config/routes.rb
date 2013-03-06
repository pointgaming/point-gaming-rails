Pointgaming::Application.routes.draw do
  resources :friend_requests
  resources :leagues
  resources :tournaments
  resources :streams
  resources :teams do
    collection do
      put 'change_active'
    end
    resources :members, controller: 'team_members'
  end
  resources :store
  resources :faq
  resources :settings
  resources :subscriptions, only: [:index, :new, :create]
  resources :user_streams do
    resources :bets, only: [:new, :show, :create, :update, :destroy]
    resources :collaborators, only: [:index, :new, :create, :destroy]
    member do
      put 'change_owner'
      put 'start'
      put 'stop'
    end
  end

  resources :games
  resources :lobbies do
    resources :rooms
  end

  namespace :admin do
    root :to => "dashboard#index"
    resources :news
  end

  namespace :api do
    namespace :v1 do
      resources :coins
      resources :games
      resources :sessions
      resources :friends
      resources :friend_requests
      resources :ignores
    end
  end

  root :to => 'home#index'

  get "/search", :to => "search#index"
  get "/search/playable", :to => "search#playable"

  get "/users/search", :to => "users#search"

  get "/users/:user_id/configs/new", :to => "user_configs#new", as: 'new_user_config'
  post "/users/:user_id/configs", :to => "user_configs#create", as: 'user_configs'
  delete "/users/:user_id/configs/:id(.:format)", :to => "user_configs#destroy", as: 'user_config'

  get "/users/:user_id/avatar/edit", :to => "user_avatar#edit", as: 'edit_user_avatar'
  put "/users/:user_id/avatar", :to => "user_avatar#update", as: 'user_avatar'

  get "/users/:user_id/profile/edit", :to => "user_profiles#edit", as: 'edit_user_profile'
  get "/users/:user_id/profile", :to => "user_profiles#show", as: 'user_profile'
  put "/users/:user_id/profile", :to => "user_profiles#update"
  get '/users/subregion_options' => 'user_profiles#subregion_options'

  devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
