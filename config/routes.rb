Rails.application.routes.draw do
  devise_for :users
  root "dashboard#dashboard"
  get "dashboard", to: "dashboard#dashboard"
  resources :students
  resources :users, only: [ :index ]
end
