require "rails_helper"

RSpec.describe "CRUD autenticado", type: :request do
  it "não deixa CRUD sem login" do
    get root_path
    expect(response).to redirect_to(login_path)

    get owners_path
    expect(response).to redirect_to(login_path)

    post owners_path, params: { owner: { name: "Maria", email: "maria@email.com" } }
    expect(response).to redirect_to(login_path)

    get pets_path
    expect(response).to redirect_to(login_path)

    post pets_path, params: { pet: { name: "Thor", species: "cão" } }
    expect(response).to redirect_to(login_path)

    get stays_path
    expect(response).to redirect_to(login_path)

    post stays_path, params: { stay: { nightly_rate_cents: 8000 } }
    expect(response).to redirect_to(login_path)
  end

  it "João cria dono, pet e stay" do
    joao = User.create!(name: "João", email: "joao@email.com", password: "senha123")
    login_as(joao)

    post owners_path, params: {
      owner: { name: "Maria", email: "maria@email.com", phone: "(11) 99999-0000" }
    }
    expect(response).to have_http_status(:redirect)
    maria = Owner.last
    expect(maria.name).to eq("Maria")
    expect(maria.user).to eq(joao)

    post pets_path, params: {
      pet: { name: "Thor", species: "cão", owner_id: maria.id }
    }
    expect(response).to have_http_status(:redirect)
    thor = Pet.last
    expect(thor.name).to eq("Thor")
    expect(thor.owner).to eq(maria)

    post stays_path, params: {
      stay: {
        pet_id: thor.id,
        check_in: Date.current.to_s,
        check_out: (Date.current + 3).to_s,
        nightly_rate_cents: 8000,
        status: "scheduled"
      }
    }
    expect(response).to have_http_status(:redirect)
    stay = Stay.last
    expect(stay.pet).to eq(thor)
    expect(stay.nights).to eq(3)
    expect(stay.total_cents).to eq(24_000)
  end
end
