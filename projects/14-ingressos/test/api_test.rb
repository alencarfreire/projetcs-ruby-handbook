# frozen_string_literal: true

require_relative "test_helper"

class ApiTest < IngressosTest
  def test_up
    get "/up"
    assert_equal 200, last_response.status
    assert_equal true, json["ok"]
    assert last_response.headers["X-Request-Id"]
  end

  def test_eventos_sem_token
    get "/eventos", {}, { "HTTP_ACCEPT" => "application/json" }
    assert_equal 401, last_response.status
  end

  def test_reservar_ok
    lote_id = seed_lote!(quantity: 2)
    post "/pedidos", JSON.generate(lote_id: lote_id, quantity: 1), auth_json
    assert_equal 201, last_response.status
    assert_equal "reserved", json["status"]
    assert_equal 8000, json["total_cents"]
    get "/lotes/#{lote_id}"
    assert_equal 1, json["quantity"]
  end

  def test_reservar_esgotado
    lote_id = seed_lote!(quantity: 1)
    post "/pedidos", JSON.generate(lote_id: lote_id, quantity: 1), auth_json
    post "/pedidos", JSON.generate(lote_id: lote_id, quantity: 1), auth_json
    assert_equal 422, last_response.status
    assert_includes json["errors"], "esgotado"
  end

  def test_webhook_hmac_invalido
    lote_id = seed_lote!(quantity: 1)
    post "/pedidos", JSON.generate(lote_id: lote_id, quantity: 1), auth_json
    pedido_id = json["id"]
    body = JSON.generate(pedido_id: pedido_id, status: "paid", idempotency_key: "k1")
    header "Authorization", nil
    post "/webhooks/pagamento", body, {
      "CONTENT_TYPE" => "application/json",
      "HTTP_X_SIGNATURE" => "nope"
    }
    assert_equal 401, last_response.status
  end

  def test_webhook_pago_e_replay
    lote_id = seed_lote!(quantity: 1)
    post "/pedidos", JSON.generate(lote_id: lote_id, quantity: 1), auth_json
    pedido_id = json["id"]
    body = JSON.generate(pedido_id: pedido_id, status: "paid", idempotency_key: "pay-1")
    sig = Hmac.sign(IngressosEnv.webhook_secret, body)
    headers = { "CONTENT_TYPE" => "application/json", "HTTP_X_SIGNATURE" => sig }
    post "/webhooks/pagamento", body, headers
    assert_equal 200, last_response.status
    assert_equal "paid", json["status"]
    post "/webhooks/pagamento", body, headers
    assert_equal 200, last_response.status
    assert_equal "paid", json["status"]
    assert_equal 1, DB[:webhook_events].count
  end

  def test_logout_denylist
    post "/create-account", JSON.generate(login: "joao@email.com", password: "senha123"), auth_json
    post "/login", JSON.generate(login: "joao@email.com", password: "senha123"), auth_json
    token = last_response.headers["Authorization"]
    post "/logout", "{}", {
      "CONTENT_TYPE" => "application/json",
      "HTTP_ACCEPT" => "application/json",
      "HTTP_AUTHORIZATION" => token
    }
    get "/eventos", {}, { "HTTP_AUTHORIZATION" => token, "HTTP_ACCEPT" => "application/json" }
    assert_equal 401, last_response.status
  end

  def test_expire_devolve_estoque
    lote_id = seed_lote!(quantity: 1)
    post "/pedidos", JSON.generate(lote_id: lote_id, quantity: 1), auth_json
    pedido_id = json["id"]
    DB[:pedidos].where(id: pedido_id).update(reserved_until: Time.now - 60)
    require_relative "../lib/expire_reservations"
    n = ExpireReservations.new.call
    assert_equal 1, n
    assert_equal "expired", DB[:pedidos].where(id: pedido_id).first[:status]
    assert_equal 1, DB[:lotes].where(id: lote_id).first[:quantity]
  end
end
