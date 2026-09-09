# Hash explícito. Sem Jbuilder, sem AMS. O entrevistador vê o JSON que sai.
module Payloads
  extend ActiveSupport::Concern

  def user_payload(user, token: false)
    payload = { id: user.id, name: user.name, email: user.email }
    payload[:token] = user.api_token if token
    payload
  end

  def owner_payload(owner)
    { id: owner.id, name: owner.name, email: owner.email, phone: owner.phone }
  end

  def pet_payload(pet)
    {
      id: pet.id,
      name: pet.name,
      species: pet.species,
      owner_id: pet.owner_id,
      owner_name: pet.owner&.name
    }
  end

  def stay_payload(stay)
    {
      id: stay.id,
      pet_id: stay.pet_id,
      pet_name: stay.pet&.name,
      owner_id: stay.owner&.id,
      owner_name: stay.owner&.name,
      check_in: stay.check_in,
      check_out: stay.check_out,
      nightly_rate_cents: stay.nightly_rate_cents,
      nights: stay.nights,
      total_cents: stay.total_cents,
      status: stay.status
    }
  end
end
