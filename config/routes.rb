Rails.application.routes.draw do
  root "students#dashboard"
  resources :students
end
