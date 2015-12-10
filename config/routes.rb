Rails.application.routes.draw do

  root 'home#index'

  resource :home
  resource :users

  
end
