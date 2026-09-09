module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :require_login, only: :create

      def create
        email = params[:email].to_s.strip.downcase
        user = User.find_by(email: email)

        if user&.authenticate(params[:password])
          user.regenerate_api_token if user.api_token.blank?
          render json: user_payload(user, token: true)
        else
          render json: { errors: ["e-mail ou senha inválidos"] }, status: :unauthorized
        end
      end

      def destroy
        current_user.regenerate_api_token
        head :no_content
      end
    end
  end
end
