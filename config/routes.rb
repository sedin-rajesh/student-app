Rails.application.routes.draw do
  devise_for :users
  root "dashboard#index"
  get "dashboard", to: "dashboard#index"
  resources :students
  resources :users, only: [ :index ]
  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post "login", to: "sessions#create"
        delete "logout", to: "sessions#destroy"
      end
      resources :students
      resources :users do
        collection do
          get :teachers_by_subject
        end
      end
      resources :teachers, only: [] do
        resources :students, only: [ :index, :create ]
      end
    end
  end
end
