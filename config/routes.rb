Rails.application.routes.draw do
  root "workspaces#index"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :workspaces, only: [:index, :create]
  resources :alerts
  resources :notification_channels do
    collection do
      get :form_fields
    end
  end
  
  mount ActionCable.server => '/cable'
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
