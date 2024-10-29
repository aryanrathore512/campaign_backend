Rails.application.routes.draw do
  namespace :api do
    resources :templates, only: [:index, :create, :show, :update, :destroy]
    resources :campaigns, only: [:index, :create, :show, :update, :destroy] do
      member do
        post :update_status
      end
    end
    resources :contacts, only: [:index] do
      collection do
        get :selected_contacts
      end
    end
  end
end
