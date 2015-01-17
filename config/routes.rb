Rails.application.routes.draw do

  namespace :api do
    resources :doctors, only: [:index, :show]
    resources :hospitals, only: [:index, :show]
  end

end
