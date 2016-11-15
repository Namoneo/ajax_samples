Rails.application.routes.draw do
  root "artists#index"

  resources :artists, only: [:index] do
    resources :songs, only: [:index, :create, :destroy]
    delete "/destroy_all", to: "songs#destroy_all", as: :songs_destroy_all
  end
end
