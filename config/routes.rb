Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get "/", to: "application#welcome"

  resources :merchants, only: [:show] do
    resources :dashboard, only: [:index]
    resources :bulk_discounts, only: [:index, :show, :new, :create]
    resources :items, except: [:destroy]
    resources :invoices, only: [:index, :show]
    resources :invoice_items, only: [:update]
  end

  resources :admin, only: [:index]

  namespace :admin do
    patch "/merchants/:id", to: "merchants#switch"
    resources :merchants, except: [:destroy]
    resources :invoices, only: [:index, :show, :update]
  end
end
