module Api
  module V1
    class OwnersController < ApplicationController
      before_action :set_owner, only: %i[show update destroy]

      def index
        owners = current_user.owners.order(:name)
        render json: owners.map { |owner| owner_payload(owner) }
      end

      def show
        render json: owner_payload(@owner)
      end

      def create
        owner = current_user.owners.new(owner_params)

        if owner.save
          render json: owner_payload(owner),
                 status: :created,
                 location: api_v1_owner_url(owner)
        else
          render_errors(owner)
        end
      end

      def update
        if @owner.update(owner_params)
          render json: owner_payload(@owner)
        else
          render_errors(@owner)
        end
      end

      def destroy
        @owner.destroy
        head :no_content
      end

      private

      def set_owner
        @owner = current_user.owners.find(params[:id])
      end

      def owner_params
        params.require(:owner).permit(:name, :email, :phone)
      end
    end
  end
end
