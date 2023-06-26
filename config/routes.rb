Rails.application.routes.draw do
  devise_for :users, skip: :all
  devise_scope :user do
    post '/users/login', to: 'users/sessions#create', as: :user_session
    post '/users', to: 'users/registrations#create', as: :user_registration
    delete '/users/logout', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  get '/account', to: 'accounts#profile', as: :user_profile

  namespace :v1 do
    resources :chats_quarters, only: :create do
      resources :messages, only: %i( index create )
    end
  end

  mount ActionCable.server => '/cable'
end
