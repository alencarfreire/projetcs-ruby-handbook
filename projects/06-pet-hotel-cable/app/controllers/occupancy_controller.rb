class OccupancyController < ApplicationController
  def index
    # N+1: pet e owner (owner via Stay has_one :owner, through: :pet).
    @stays = current_user.stays.checked_in.includes(:pet, :owner).order(:check_in)
  end
end
