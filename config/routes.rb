Rails.application.routes.draw do

  resources :doctors, only: [:index, :show]
  resources :hospitals, only: [:index, :show]
  resources :specialities, only: [:index, :show]

end
