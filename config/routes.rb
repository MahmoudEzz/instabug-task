Rails.application.routes.draw do
  resources :applications, param: :token do
    resources :chats, param: :number
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
