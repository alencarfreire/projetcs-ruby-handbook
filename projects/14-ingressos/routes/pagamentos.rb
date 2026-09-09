# frozen_string_literal: true

require "json"
require "securerandom"
require_relative "../lib/hmac"
require_relative "../lib/env"

class App
  hash_branch "pagamentos" do |r|
    require_login!

    r.post "simular" do
      pedido_id = r.params["pedido_id"].to_i
      status = r.params["status"].to_s
      status = "paid" if status.empty?
      pedido = DB[:pedidos].where(id: pedido_id, account_id: rodauth.session_value).first
      r.halt(404, { "errors" => ["não encontrado"] }) unless pedido

      payload = JSON.generate(
        "pedido_id" => pedido[:id],
        "status" => status,
        "idempotency_key" => "sim-#{pedido[:id]}-#{SecureRandom.hex(4)}"
      )
      {
        "url" => "/webhooks/pagamento",
        "payload" => JSON.parse(payload),
        "signature" => Hmac.sign(IngressosEnv.webhook_secret, payload)
      }
    end
  end
end
