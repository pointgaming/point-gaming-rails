PointGamingRails::Application.routes.draw do
  resources :tournaments do
    resources :registrations, only: [:create, :update, :destroy]
    resources :sponsors, except: [:index, :show]
    resources :invites, only: [:create, :destroy]
    resources :payments, only: [:new, :create]

    resources :seeds, only: [:index, :destroy] do
      collection do
        put "update"
      end
    end

    collection do
      get     "collaborated"
      post    "markdown"
    end

    member do
      get     "users"
      get     "brackets"
      put     "collaborators"
      post    "report_scores"
    end
  end
end
