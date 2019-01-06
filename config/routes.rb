Rails.application.routes.draw do
  post 'users/login' => 'users#login', :as => :login
  get 'users/login' => 'users#login_view', :as => :login_view
  resources :rooms do
    resources :messages
  end
  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
