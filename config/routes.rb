Rails.application.routes.draw do

  root 'home#index'

  resource :home
  resources :users

  
end
