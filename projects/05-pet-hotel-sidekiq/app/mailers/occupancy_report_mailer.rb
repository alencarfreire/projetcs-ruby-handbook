class OccupancyReportMailer < ApplicationMailer
  def daily(user, stays)
    @user = user
    @stays = stays
    mail to: user.email, subject: "Ocupação de hoje — Pousada do Thor"
  end
end
