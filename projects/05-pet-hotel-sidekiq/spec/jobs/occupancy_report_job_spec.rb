require "rails_helper"

RSpec.describe OccupancyReportJob, type: :job do
  it "manda o relatório com quem está checked_in" do
    joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
    maria = joao.owners.create!(name: "Maria", email: "maria@email.com")
    thor = joao.pets.create!(name: "Thor", species: "cão", owner: maria)
    luna = joao.pets.create!(name: "Luna", species: "gato", owner: maria)
    joao.stays.create!(
      pet: thor,
      check_in: Date.current,
      check_out: Date.current + 3,
      nightly_rate_cents: 8000,
      status: :checked_in
    )
    joao.stays.create!(
      pet: luna,
      check_in: Date.current + 5,
      check_out: Date.current + 8,
      nightly_rate_cents: 7000,
      status: :scheduled
    )

    described_class.perform_now(joao.id)

    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq(["joao@email.com"])
    expect(mail.body.encoded).to include("Thor")
    expect(mail.body.encoded).not_to include("Luna")
  end
end
