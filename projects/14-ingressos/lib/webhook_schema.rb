# frozen_string_literal: true

require_relative "result"

# D: contrato do JSON do PSP. Antes de ConfirmarPagamento.
class WebhookSchema
  STATUSES = %w[paid failed].freeze

  def self.call(params)
    params = stringify(params)
    errors = []
    errors << "pedido_id obrigatório" if params["pedido_id"].to_s.empty?
    errors << "status inválido" unless STATUSES.include?(params["status"].to_s)
    errors << "idempotency_key obrigatória" if params["idempotency_key"].to_s.empty?
    return Result.err(errors) if errors.any?

    Result.ok(
      "pedido_id" => params["pedido_id"].to_i,
      "status" => params["status"].to_s,
      "idempotency_key" => params["idempotency_key"].to_s
    )
  end

  def self.stringify(params)
    params.each_with_object({}) { |(k, v), h| h[k.to_s] = v }
  end
end
