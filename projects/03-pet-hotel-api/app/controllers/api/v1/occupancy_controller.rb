module Api
  module V1
    class OccupancyController < ApplicationController
      def index
        stays = current_user.stays.checked_in.includes(:pet, :owner).order(:check_in)
        render json: stays.map { |stay| stay_payload(stay) }
      end
    end
  end
end
