Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Autenticação (endpoints públicos)
      post "signup", to: "registrations#create"
      post "login",  to: "sessions#create"

      # Recursos de negócio (exigem JWT, escopados por current_user).
      # Shallow nesting: coleção/criação carregam o pai na URL; ações de membro
      # (show/update/destroy) ficam flat, pelo id próprio do recurso.
      resources :farms do
        resources :fields, shallow: true
      end
      resources :fields, only: [] do
        resources :sensors, shallow: true
      end
      resources :sensors, only: [] do
        # Leituras só são criadas e listadas (sem editar/remover uma leitura solta).
        resources :readings, only: %i[index create]
        # Médias + alertas do sensor no período (?period=24h|7d|30d).
        get :summary, on: :member
      end
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
