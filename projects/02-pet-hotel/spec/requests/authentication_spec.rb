require "rails_helper"

RSpec.describe "Authentication", type: :request do
  it "permite cadastro, login e logout" do
    get signup_path
    expect(response).to have_http_status(:ok)

    post signup_path, params: {
      user: {
        name: "João",
        email: "joao@email.com",
        password: "senha123",
        password_confirmation: "senha123"
      }
    }
    expect(response).to redirect_to(root_path)
    follow_redirect!
    expect(response.body).to include("Quem está no hotel agora")

    delete logout_path
    expect(response).to redirect_to(login_path)

    post login_path, params: { email: "joao@email.com", password: "senha123" }
    expect(response).to redirect_to(root_path)
  end

  it "rejeita senha curta no cadastro" do
    post signup_path, params: {
      user: {
        name: "João",
        email: "joao@email.com",
        password: "curta",
        password_confirmation: "curta"
      }
    }
    expect(response).to have_http_status(422)
    expect(User.count).to eq(0)
  end
end
