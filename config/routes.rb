Rails.application.routes.draw do
  devise_for :users
  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end
  unauthenticated do
    root to: redirect("/users/sign_in")
  end
  get "dashboard", to: "dashboard#index"
  resources :students
  resources :students do
    member do
      delete :remove_profile_photo
    end
  end
  resources :students do
    delete :remove_document, on: :member
  end
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
