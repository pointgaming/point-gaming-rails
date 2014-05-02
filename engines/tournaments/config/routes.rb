PointGamingRails::Application.routes.draw do
  resources :tournaments do
    resources :registrations, only: [:create, :update, :destroy]
    resources :invites,       only: [:create, :destroy]
    resources :admins,        only: [:create, :destroy]
    resources :sponsors,      except: [:index, :show]

    resources :seeds, only: [:index, :destroy] do
      collection do
        put "update"
      end
    end

    collection do
      get   "collaborated"
      post  "markdown"
    end

    member do
      get   "brackets"
      post  "report_scores"
    end
  end
end
