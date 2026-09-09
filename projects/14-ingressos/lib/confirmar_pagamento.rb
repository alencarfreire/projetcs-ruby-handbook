# frozen_string_literal: true

require "json"
require_relative "result"

# C: paid não baixa estoque de novo (já baixou na reserva).
# failed devolve estoque se ainda reserved.
class ConfirmarPagamento
  def initialize(db: DB)
    @db = db
  end

  def call(pedido_id:, status:, idempotency_key:, payload: nil)
    existing = @db[:webhook_events].where(idempotency_key: idempotency_key).first
    if existing
      pedido = @db[:pedidos].where(id: existing[:pedido_id]).first
      return Result.ok(pedido)
    end

    # UniqueConstraintViolation no Postgres aborta a transação. Rescue fora, não dentro.
    begin
      @db.transaction do
        pedido = @db[:pedidos].where(id: pedido_id).first
        raise Sequel::Rollback unless pedido

        @db[:webhook_events].insert(
          idempotency_key: idempotency_key,
          pedido_id: pedido_id,
          status: status,
          payload: payload || JSON.generate(pedido_id: pedido_id, status: status),
          created_at: Time.now
        )

        case status
        when "paid"
          if pedido[:status] == "reserved"
            @db[:pedidos].where(id: pedido_id, status: "reserved").update(status: "paid")
          end
        when "failed"
          n = @db[:pedidos].where(id: pedido_id, status: "reserved").update(status: "failed")
          if n.positive?
            @db[:lotes].where(id: pedido[:lote_id]).update(quantity: Sequel[:quantity] + pedido[:quantity])
          end
        end
      end
    rescue Sequel::UniqueConstraintViolation
      return Result.ok(@db[:pedidos].where(id: pedido_id).first)
    end

    pedido = @db[:pedidos].where(id: pedido_id).first
    return Result.err("pedido não encontrado") unless pedido

    Result.ok(pedido)
  end
end
