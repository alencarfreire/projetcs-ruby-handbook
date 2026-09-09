require "rails_helper"

RSpec.describe "Stays e ocupação", type: :request do
  def create_hotel
    joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
    maria = joao.owners.create!(name: "Maria", email: "maria@email.com", phone: "(11) 99999-0000")
    thor = joao.pets.create!(name: "Thor", species: "cão", owner: maria)
    luna = joao.pets.create!(name: "Luna", species: "gato", owner: maria)
    [joao, maria, thor, luna]
  end

  it "não deixa duas stays checked_in no mesmo pet" do
    joao, _maria, thor, _luna = create_hotel

    joao.stays.create!(
      pet: thor,
      check_in: Date.current,
      check_out: Date.current + 2,
      nightly_rate_cents: 8000,
      status: :checked_in
    )

    post "/api/v1/stays",
         params: {
           stay: {
             pet_id: thor.id,
             check_in: Date.current.to_s,
             check_out: (Date.current + 4).to_s,
             nightly_rate_cents: 8000,
             status: "checked_in"
           }
         },
         headers: auth_headers(joao),
         as: :json

    expect(response).to have_http_status(422)
    expect(json_body["errors"]).to be_present
    expect(Stay.checked_in.where(pet: thor).count).to eq(1)
  end

  it "lista na ocupação só quem está checked_in" do
    joao, _maria, thor, luna = create_hotel

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

    get "/api/v1/occupancy", headers: auth_headers(joao), as: :json
    expect(response).to have_http_status(:ok)
    names = json_body.map { |row| row["pet_name"] }
    expect(names).to include("Thor")
    expect(names).not_to include("Luna")
  end

  it "total_cents = nights * nightly_rate_cents e aparece no JSON" do
    joao, _maria, thor, _luna = create_hotel
    stay = joao.stays.create!(
      pet: thor,
      check_in: Date.new(2026, 8, 25),
      check_out: Date.new(2026, 8, 28),
      nightly_rate_cents: 8000,
      status: :scheduled
    )

    expect(stay.nights).to eq(3)
    expect(stay.total_cents).to eq(24_000)

    get "/api/v1/stays/#{stay.id}", headers: auth_headers(joao), as: :json
    expect(response).to have_http_status(:ok)
    expect(json_body["nights"]).to eq(3)
    expect(json_body["total_cents"]).to eq(24_000)
    expect(json_body["nightly_rate_cents"]).to eq(8000)
  end

  it "check-in e check-out mudam o status no JSON" do
    joao, _maria, thor, _luna = create_hotel
    stay = joao.stays.create!(
      pet: thor,
      check_in: Date.current,
      check_out: Date.current + 2,
      nightly_rate_cents: 8000,
      status: :scheduled
    )

    post "/api/v1/stays/#{stay.id}/check_in", headers: auth_headers(joao), as: :json
    expect(response).to have_http_status(:ok)
    expect(json_body["status"]).to eq("checked_in")

    post "/api/v1/stays/#{stay.id}/check_out", headers: auth_headers(joao), as: :json
    expect(response).to have_http_status(:ok)
    expect(json_body["status"]).to eq("checked_out")
  end
end
