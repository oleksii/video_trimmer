module Api
  module V1
    class UsersController < ApplicationController
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
  end
end
