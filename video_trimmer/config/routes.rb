require 'api_constraints'

VideoTrimmer::Application.routes.draw do
  namespace :api, defaults: {format: 'json'} do
    scope module: :v1, constraints: ApiConstraints.new(version: 1, default: true) do
    end
  end
end
