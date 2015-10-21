Rails.application.routes.draw do


  scope '/:locale', :locale => /de|fr|it|en/, :format => /json|html/ do
    devise_for :users

    resources :hospitals, only: [:index, :show]
    resources :specialities, only: [:index, :show]

    resources :variables do
      post :set_variable_sets, :on => :member
    end

    get '/entry', to: 'home#entry', as: 'entry'
    get '/about', to: 'home#home', as: 'about'
    get '/help', to: 'home#home', as: 'help'

    get '', to: 'home#home', as: 'home'
  end

  root to: 'home#redirect'
end
