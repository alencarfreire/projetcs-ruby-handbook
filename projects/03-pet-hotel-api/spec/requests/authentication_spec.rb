require "rails_helper"

RSpec.describe "Authentication", type: :request do
  it "permite cadastro, login e logout com token" do
    post "/api/v1/signup", params: {
      user: {
        name: "João",
        email: "joao@email.com",
        password: "senha123",
        password_confirmation: "senha123"
      }
    }, as: :json

    expect(response).to have_http_status(:created)
    token = json_body["token"]
    expect(token).to be_present
    expect(json_body["email"]).to eq("joao@email.com")
    expect(json_body).not_to have_key("password_digest")

    delete "/api/v1/logout", headers: { "Authorization" => "Bearer #{token}" }
    expect(response).to have_http_status(:no_content)

    get "/api/v1/occupancy", headers: { "Authorization" => "Bearer #{token}" }
    expect(response).to have_http_status(:unauthorized)

    post "/api/v1/login", params: { email: "joao@email.com", password: "senha123" }, as: :json
    expect(response).to have_http_status(:ok)
    new_token = json_body["token"]
    expect(new_token).to be_present
    expect(new_token).not_to eq(token)

    get "/api/v1/occupancy", headers: { "Authorization" => "Bearer #{new_token}" }
    expect(response).to have_http_status(:ok)
    expect(json_body).to eq([])
  end

  it "rejeita senha curta no cadastro" do
    post "/api/v1/signup", params: {
      user: {
        name: "João",
        email: "joao@email.com",
        password: "curta",
        password_confirmation: "curta"
      }
    }, as: :json

    expect(response).to have_http_status(422)
    expect(json_body["errors"]).to be_present
    expect(User.count).to eq(0)
  end

  it "rejeita login com senha errada" do
    User.create!(name: "João", email: "joao@email.com", password: "senha123")

    post "/api/v1/login", params: { email: "joao@email.com", password: "errada999" }, as: :json
    expect(response).to have_http_status(:unauthorized)
    expect(json_body["errors"]).to include("e-mail ou senha inválidos")
  end
end
