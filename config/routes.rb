Rails.application.routes.draw do
  get "teachers/index"
  devise_for :users
  root "students#dashboard"
  resources :students
  resources :teachers, only: [:index]
end
