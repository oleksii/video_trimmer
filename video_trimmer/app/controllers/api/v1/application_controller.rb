class Api::V1::ApplicationController < ActionController::API
  before_action :authenticate_request

  attr_reader :current_user

  private

  def authenticate_request
    command = ::ApiRequestAuthorizer.call(request.headers)

    if command.success?
      @current_user = command.result
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end
end
