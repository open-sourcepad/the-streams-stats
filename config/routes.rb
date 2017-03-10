Rails.application.routes.draw do
  devise_for :users
  
  root 'dashboard#index'

  namespace :admin,  module: :admin do
    root 'dashboard#index'

    resources :day_offs
    resources :holidays
    resources :users
  end
end
