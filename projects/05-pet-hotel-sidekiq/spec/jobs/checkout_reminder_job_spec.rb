require "rails_helper"

RSpec.describe CheckoutReminderJob, type: :job do
  def create_stay(status:)
    joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
    maria = joao.owners.create!(name: "Maria", email: "maria@email.com")
    thor = joao.pets.create!(name: "Thor", species: "cão", owner: maria)
    joao.stays.create!(
      pet: thor,
      check_in: Date.current,
      check_out: Date.current + 3,
      nightly_rate_cents: 8000,
      status: status
    )
  end

  it "manda mail se a stay ainda está checked_in" do
    stay = create_stay(status: :checked_in)

    described_class.perform_now(stay.id)

    expect(ActionMailer::Base.deliveries.size).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq(["joao@email.com"])
    expect(mail.subject).to include("Thor")
  end

  it "não manda mail se já fez check-out" do
    stay = create_stay(status: :checked_out)

    described_class.perform_now(stay.id)

    expect(ActionMailer::Base.deliveries).to be_empty
  end

  it "descarta se a stay sumiu" do
    expect { described_class.perform_now(9_999_999) }.not_to raise_error
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end
