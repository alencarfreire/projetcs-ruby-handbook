class CheckoutReminderJob < ApplicationJob
  queue_as :mailers
  discard_on ActiveRecord::RecordNotFound

  def perform(stay_id)
    stay = Stay.includes(:pet, :owner, :user).find(stay_id)
    return unless stay.checked_in?

    CheckoutReminderMailer.remind(stay).deliver_now
  end
end
