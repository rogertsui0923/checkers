Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :games, only: [:index, :create, :show] do
    resources :moves, only: [:create]
  end

  # mount ActionCable.server, at: '/game'
end
