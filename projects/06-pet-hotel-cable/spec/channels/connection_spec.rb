require "rails_helper"

RSpec.describe ApplicationCable::Connection, type: :channel do
  it "identifica o user da session" do
    joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
    connect "/cable", session: { user_id: joao.id }
    expect(connection.current_user).to eq(joao)
  end

  it "rejeita anônimo" do
    expect { connect "/cable" }.to have_rejected_connection
  end
end
