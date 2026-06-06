# Rails.application.routes.draw do
#   get "pages/home"
#   get "studios/index"
#   get "studios/show"
#   get "genres/index"
#   get "genres/show"
#   get "animes/index"
#   get "animes/show"
#   # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

#   # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
#   # Can be used by load balancers and uptime monitors to verify that the app is live.
#   get "up" => "rails/health#show", as: :rails_health_check

#   # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
#   # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
#   # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

#   # Defines the root path route ("/")
#   # root "posts#index"
#   root "pages#home"

#   resources :animes,  only: [:index, :show]
#   resources :genres,  only: [:index, :show]
#   resources :studios, only: [:index, :show]
# end

Rails.application.routes.draw do
  root "animes#index"  # ← remplacer "pages#home"

  resources :animes,  only: [:index, :show]
  resources :genres,  only: [:index, :show]
  resources :studios, only: [:index, :show]
end
