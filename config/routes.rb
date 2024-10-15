Rails.application.routes.draw do
  namespace :api do
    resources :templates, only: [:index, :create, :show, :update, :destroy]
    resources :campaigns, only: [:index, :create, :show, :update, :destroy]
  end
end
