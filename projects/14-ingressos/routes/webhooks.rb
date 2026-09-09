# frozen_string_literal: true

require_relative "../lib/hmac"
require_relative "../lib/env"
require_relative "../lib/webhook_schema"
require_relative "../lib/confirmar_pagamento"
require_relative "../lib/sidekiq_optional"

class App
  hash_branch "webhooks" do |r|
    r.post "pagamento" do
      body = env["RAW_BODY"] || request.body.read
      sig = env["HTTP_X_SIGNATURE"].to_s
      r.halt(401, { "error" => "assinatura inválida" }) unless Hmac.valid?(IngressosEnv.webhook_secret, body, sig)

      raw = begin
        JSON.parse(body)
      rescue JSON::ParserError
        r.halt(400, { "errors" => ["JSON inválido"] })
      end

      schema = WebhookSchema.call(raw)
      r.halt(422, { "errors" => schema.errors }) unless schema.ok?

      result = ConfirmarPagamento.new.call(
        pedido_id: schema.value["pedido_id"],
        status: schema.value["status"],
        idempotency_key: schema.value["idempotency_key"],
        payload: body
      )
      r.halt(404, { "errors" => result.errors }) unless result.ok?

      pedido = result.value
      SidekiqOptional.enqueue_mail(pedido[:id]) if pedido && pedido[:status] == "paid"
      pedido
    end
  end
end
