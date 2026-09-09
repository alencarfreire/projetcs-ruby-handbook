module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :require_login, only: :create

      def create
        user = User.new(user_params)

        if user.save
          render json: user_payload(user, token: true), status: :created
        else
          render_errors(user)
        end
      end

      private

      def user_params
        params.require(:user).permit(:name, :email, :password, :password_confirmation)
      end
    end
  end
end
