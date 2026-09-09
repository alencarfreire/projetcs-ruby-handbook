require "rails_helper"

RSpec.describe "CRUD autenticado", type: :request do
  it "não deixa CRUD sem token" do
    get "/api/v1/occupancy", as: :json
    expect(response).to have_http_status(:unauthorized)

    get "/api/v1/owners", as: :json
    expect(response).to have_http_status(:unauthorized)

    post "/api/v1/owners", params: { owner: { name: "Maria", email: "maria@email.com" } }, as: :json
    expect(response).to have_http_status(:unauthorized)

    get "/api/v1/pets", as: :json
    expect(response).to have_http_status(:unauthorized)

    get "/api/v1/stays", as: :json
    expect(response).to have_http_status(:unauthorized)
  end

  it "João cria dono, pet e stay" do
    joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")

    post "/api/v1/owners",
         params: { owner: { name: "Maria", email: "maria@email.com", phone: "(11) 99999-0000" } },
         headers: auth_headers(joao),
         as: :json
    expect(response).to have_http_status(:created)
    expect(response.headers["Location"]).to be_present
    maria = Owner.last
    expect(maria.name).to eq("Maria")
    expect(maria.user).to eq(joao)
    expect(json_body["name"]).to eq("Maria")

    post "/api/v1/pets",
         params: { pet: { name: "Thor", species: "cão", owner_id: maria.id } },
         headers: auth_headers(joao),
         as: :json
    expect(response).to have_http_status(:created)
    thor = Pet.last
    expect(thor.name).to eq("Thor")
    expect(thor.owner).to eq(maria)
    expect(json_body["owner_name"]).to eq("Maria")

    post "/api/v1/stays",
         params: {
           stay: {
             pet_id: thor.id,
             check_in: Date.current.to_s,
             check_out: (Date.current + 3).to_s,
             nightly_rate_cents: 8000,
             status: "scheduled"
           }
         },
         headers: auth_headers(joao),
         as: :json
    expect(response).to have_http_status(:created)
    stay = Stay.last
    expect(stay.pet).to eq(thor)
    expect(stay.nights).to eq(3)
    expect(stay.total_cents).to eq(24_000)
    expect(json_body["nights"]).to eq(3)
    expect(json_body["total_cents"]).to eq(24_000)
  end

  it "não mostra o owner de outro user — 404, não 401" do
    joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
    ana = User.create!(name: "Ana", email: "ana@email.com", password: "senha123")
    maria = joao.owners.create!(name: "Maria", email: "maria@email.com")

    get "/api/v1/owners/#{maria.id}", headers: auth_headers(ana), as: :json
    expect(response).to have_http_status(:not_found)
    expect(json_body["errors"]).to include("não encontrado")
  end
end
