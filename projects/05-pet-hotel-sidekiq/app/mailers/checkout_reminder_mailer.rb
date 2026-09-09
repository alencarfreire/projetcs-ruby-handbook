class CheckoutReminderMailer < ApplicationMailer
  def remind(stay)
    @stay = stay
    @pet = stay.pet
    mail to: stay.user.email, subject: "#{@pet.name} sai hoje — Pousada do Thor"
  end
end
