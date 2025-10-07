Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Calendar routes
  get "calendar", to: "calendar#index", as: :calendar_index

  # Cancellation routes
  post 'slots/:slot_id/cancel', to: 'cancellations#create', as: :cancel_slot
  delete 'slots/:slot_id/restore/:user_id', to: 'cancellations#destroy', as: :restore_slot

  # Defines the root path route ("/")
  root "calendar#index"
end
