Rails.application.routes.draw do

  scope '/:locale', :locale => /de|fr|it|en/, :format => /json|html/ do
    resources :doctors, only: [:index, :show]
    resources :hospitals, only: [:index, :show]
    resources :specialities, only: [:index, :show]
    resources :icds,  id: /[\w\.]+?/, only: [:index, :show]
    resources :chops, id: /[\w\.]+?/, only: [:index, :show]

    get '/about', to: 'home#home', as: 'about'
    get '/help', to: 'home#home', as: 'help'

    get '', to: 'home#home', as: 'home'
  end

  root to: 'home#redirect'
end
