Rails.application.routes.draw do
  get "alerts/index"
  root "workspaces#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :workspaces, only: [:index, :create]
  
  # Action Cable mount point
  mount ActionCable.server => '/cable'
end
