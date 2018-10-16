class Api::V1::UsersController < Api::V1::ApplicationController
  skip_before_action :authenticate_request

  def create
    @user = User.new

    if @user.save
      subscribtion_key = JsonWebToken.encode(user_id: @user.id.to_s)

      render json: { token: subscribtion_key }, status: :created
    else
      render json: { error: @user.errors.messages }, status: :unprocessable_entity
    end
  end
end
