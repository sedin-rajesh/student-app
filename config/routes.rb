Rails.application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  devise_for :users
  authenticated :user do
    root "dashboard#index", as: :authenticated_root
  end
  unauthenticated do
    root to: redirect("/users/sign_in")
  end
  get "dashboard", to: "dashboard#index"
  resources :students do
    member do
      delete :remove_profile_photo
      delete :remove_document
    end
  end
  resources :users, only: [ :index ]
  namespace :api do
    namespace :v1 do
      devise_scope :user do
        post "login", to: "sessions#create"
        delete "logout", to: "sessions#destroy"
      end
      resources :students do
        member do
          get :report_card
        end
      end
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
