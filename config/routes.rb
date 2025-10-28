Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  constraints(AdminConstraint.new) do
    mount Motor::Admin => '/admin'
  end

  get '/auth/:provider/callback' => 'sessions#omni_auth_create'
  get '/auth/failure' => 'sessions#omni_auth_failure'

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Calendar routes
  get "calendar", to: "calendar#index", as: :calendar_index

  resources :slots, only: [] do
    get :refresh, on: :member

    post :cancel, on: :member, to: 'cancellations#create'
    resources :bookings, only: [:create, :destroy]
  end

  resource :profile, only: [:edit, :update]

  # Defines the root path route ("/")
  root "calendar#index"
end
