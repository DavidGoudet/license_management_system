Rails.application.routes.draw do
  root "accounts#index"

  resources :products

  resources :accounts do
    resources :users, only: [ :index, :new, :create ]
    resources :subscriptions, only: [ :index, :new, :create ]

    resources :license_assignments, only: [ :index, :create, :destroy ] do
      collection do
        delete :bulk_destroy
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
