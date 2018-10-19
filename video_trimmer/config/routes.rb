require 'api_constraints'
require 'sidekiq/web'

VideoTrimmer::Application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  mount Raddocs::App => '/docs'
  mount VideoUploader.download_endpoint => '/attachments'

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users, only: :create
      resources :videos, only: [:create, :index] do
        collection { patch 'restart' }
      end
    end
  end
end
