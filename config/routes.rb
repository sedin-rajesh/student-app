Rails.application.routes.draw do
  devise_for :users, defaults: { format: :json },
  controllers: {
    sessions: "users/sessions"
  }
  root "dashboard#dashboard"
  get "dashboard", to: "dashboard#dashboard"
  resources :students
  get  "/teachers/:teacher_id/students",
      to: "students#teacher_students"
  post "/teachers/:teacher_id/students",
      to: "students#create_for_teacher"
  resources :users do
    collection do
      get :teachers_by_subject
    end
  end
  resources :teachers, only: [] do
    resources :students, only: [ :index, :create ]
  end
end
