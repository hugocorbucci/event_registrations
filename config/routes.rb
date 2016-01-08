Current::Application.routes.draw do
  post '/auth/:provider/callback', to: 'sessions#create'
  get '/auth/:provider/callback', to: 'sessions#create' # due problems without dev backdoor

  get '/auth/failure', to: 'sessions#failure'
  get '/login', to: 'sessions#new', as: :login
  delete '/logout', to: 'sessions#destroy', as: :logout

  resources :users, only: %i(show edit update)

  resources :events, only: %i(index show new create destroy) do
    collection do
      get :list_archived
    end

    resources :attendances, only: %i(new create edit update), controller: :event_attendances do
      collection do
        get :by_state
        get :by_city
        get :pending_attendances
        get :last_biweekly_active
        get :to_approval
        get :payment_type_report
      end
    end
    resources :registration_groups, only: %i(index destroy show create) do
      member do
        put :renew_invoice
      end
    end

    resources :payments, only: :checkout do
      member do
        post :checkout
      end
    end

    resources :registration_periods, only: [:new, :create]
    resources :registration_quotas, only: [:new, :create]
  end

  get '/attendance_statuses/:id', to: redirect('/attendances/%{id}')
  post '/attendance_statuses/:id', to: redirect('/attendances/%{id}')
  resources :attendances, only: %i(show index) do
    member do
      put :confirm
      put :pay_it
      put :accept_it
      delete :destroy
      put :recover_it
    end

    resources :transfers, only: :new
  end

  resources :payment_notifications, only: :create
  resources :transfers, only: :create

  root to: 'events#index'
end
