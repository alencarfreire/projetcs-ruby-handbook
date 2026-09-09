module Api
  module V1
    class StaysController < ApplicationController
      before_action :set_stay, only: %i[show update destroy check_in check_out]

      def index
        stays = current_user.stays.includes(:pet, :owner).order(check_in: :desc)
        render json: stays.map { |stay| stay_payload(stay) }
      end

      def show
        render json: stay_payload(@stay)
      end

      def create
        stay = current_user.stays.new(stay_params)

        if stay.save
          render json: stay_payload(stay),
                 status: :created,
                 location: api_v1_stay_url(stay)
        else
          render_errors(stay)
        end
      end

      def update
        if @stay.update(stay_params)
          render json: stay_payload(@stay)
        else
          render_errors(@stay)
        end
      end

      def destroy
        @stay.destroy
        head :no_content
      end

      def check_in
        if @stay.update(status: :checked_in)
          render json: stay_payload(@stay)
        else
          render_errors(@stay)
        end
      end

      def check_out
        if @stay.update(status: :checked_out)
          render json: stay_payload(@stay)
        else
          render_errors(@stay)
        end
      end

      private

      def set_stay
        @stay = current_user.stays.includes(:pet, :owner).find(params[:id])
      end

      def stay_params
        params.require(:stay).permit(:pet_id, :check_in, :check_out, :nightly_rate_cents, :status)
      end
    end
  end
end
