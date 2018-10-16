require 'api_constraints'

VideoTrimmer::Application.routes.draw do
  mount Raddocs::App => "/docs"

  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
      resources :users, only: :create
      resources :videos, only: :create
    end
  end
end
