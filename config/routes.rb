Rails.application.routes.draw do
  resources :companies
  get 'welcome/index'
  root 'companies#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
