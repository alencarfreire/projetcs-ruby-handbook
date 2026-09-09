class OccupancyReportJob < ApplicationJob
  queue_as :mailers
  discard_on ActiveRecord::RecordNotFound

  def perform(user_id)
    user = User.find(user_id)
    stays = user.stays.checked_in.includes(:pet, :owner).order(:check_in)

    OccupancyReportMailer.daily(user, stays.to_a).deliver_now
  end
end
