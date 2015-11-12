Rails.application.routes.draw do
  scope '/:locale', :locale => /de|fr|it|en/, :format => /json|html/ do
    devise_for :users

    resources :hospital_locations, only: [:index, :show]
    resources :comparisons, only: [:index, :show]

    namespace :admin do
      get '', to: 'hospitals#index', as: 'home'

      resources :variables do
        post :set_variable_sets, :on => :member
      end
      resources :hospitals
      resources :hospital_locations
      resources :comparisons
    end

    get '/entry', to: 'home#entry', as: 'entry'
    get '/about', to: 'home#home', as: 'about'
    get '/help', to: 'home#home', as: 'help'

    get '', to: 'home#home', as: 'home'
  end

  root to: 'home#redirect'
end
