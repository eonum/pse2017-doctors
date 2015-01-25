Rails.application.routes.draw do

  scope '/:locale', :locale => /de|fr|it|en/ do
    resources :doctors, only: [:index, :show]
    resources :hospitals, only: [:index, :show]
    resources :specialities, only: [:index, :show]
    resources :icds,  id: /[\w\.]+?/, format: /json|xml/, only: [:index, :show]
    resources :chops, id: /[\w\.]+?/, format: /json|xml/, only: [:index, :show]
  end

end
