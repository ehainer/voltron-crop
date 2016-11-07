Rails.application.routes.draw do

  resources :users

  resources :tests

  root to: "users#index"

end
