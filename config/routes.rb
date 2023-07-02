Rails.application.routes.draw do
  devise_for :users, skip: :all
  devise_scope :user do
    get '/users/account', to: 'users/accounts#profile', as: :user_profile
    get '/users/refresh_session', to: 'users/accounts#refresh_session', as: :refresh_user_session
    get '/users/signed_user', to: 'users/accounts#signed_user', as: :session_signed_user
    post '/users/login', to: 'users/sessions#create', as: :user_session
    post '/users', to: 'users/registrations#create', as: :user_registration
    delete '/users/logout', to: 'users/sessions#destroy', as: :destroy_user_session
  end

  namespace :v1 do
    resources :chats_quarters, only: %i( index create ) do
      resources :messages, only: %i( index create )
    end
  end

  mount ActionCable.server => '/cable'
end
