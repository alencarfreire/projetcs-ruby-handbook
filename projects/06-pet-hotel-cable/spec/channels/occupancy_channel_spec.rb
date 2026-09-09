require "rails_helper"

RSpec.describe OccupancyChannel, type: :channel do
  it "inscreve no stream do user" do
    joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
    stub_connection current_user: joao
    subscribe
    expect(subscription).to be_confirmed
    expect(subscription).to have_stream_for(joao)
  end
end
