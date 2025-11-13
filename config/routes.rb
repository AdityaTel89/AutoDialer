Rails.application.routes.draw do
  root "dashboard#index"
  
  resources :calls, only: [:index, :show] do
    collection do
      get :stats
    end
  end
  
  post "dashboard/upload", to: "dashboard#upload"
  post "dashboard/paste_numbers", to: "dashboard#paste_numbers"
  post "dashboard/make_single_call", to: "dashboard#make_single_call"
  
  namespace :webhooks do
    post :voice
    post :status
  end
  
  mount ActionCable.server => '/cable'
end
