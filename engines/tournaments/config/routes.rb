PointGamingRails::Application.routes.draw do
  resources :tournaments do
    resources :players, only: [:create, :update, :destroy]
    resources :sponsors, except: [:index, :show]
    resources :invites, only: [:create, :destroy]
    resources :payments, only: [:new, :create]

    collection do
      get "collaborated"
    end

    member do
      get "prize_pool"
      get "status"
      get "users"
      get "brackets"
      get "seeds"
      put "seeds"
      put "collaborators"
      post "report_scores"
    end
  end
end
