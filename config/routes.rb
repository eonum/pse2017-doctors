Rails.application.routes.draw do
  scope '/:locale', :locale => /de|fr|it|en/, :format => /json|html/ do
    devise_for :users

    resources :hospitals, only: [:show] do
      get :field, :on => :member
    end
    resources :comparisons, only: [:index, :show]

    namespace :admin do
      get '', to: 'hospitals#index', as: 'home'

      resources :variables, except: ['show'] do
        post :set_variable_sets, :on => :member
        get :search, :on => :collection
      end
      resources :hospitals, except: ['show'] do
        resources :fields, except: [:create]
        post :create_location, :on => :member
        post :geolocate, :on => :member
      end
      resources :hospital_locations, except: ['show']
      resources :doctors do
        post :geolocate, :on => :member
      end
      resources :comparisons
    end

    get '/about', to: 'home#about', as: 'about'
    get '/help', to: 'home#help', as: 'help'

    get '', to: 'comparisons#index', as: 'home'
  end

  root to: 'home#redirect'
end
