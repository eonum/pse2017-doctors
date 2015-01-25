Rails.application.routes.draw do

  scope '/:locale', :locale => /de|fr|it|en/ do
    resources :doctors, only: [:index, :show]
    resources :hospitals, only: [:index, :show]
    resources :specialities, only: [:index, :show]
    resources :icds, only: [:index, :show]
    resources :chops, only: [:index, :show]
  end

end
