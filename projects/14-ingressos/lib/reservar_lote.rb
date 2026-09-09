# frozen_string_literal: true

require_relative "result"

# C: regra de estoque. Sem Roda. UPDATE condicional, não quantity -= 1 em Ruby.
class ReservarLote
  TTL = 15 * 60

  def initialize(db: DB)
    @db = db
  end

  def call(account_id:, lote_id:, quantity:)
    qty = quantity.to_i
    return Result.err("quantity inválida") if qty < 1

    @db.transaction do
      lote = @db[:lotes].where(id: lote_id).first
      return Result.err("lote não encontrado") unless lote

      now = Time.now
      if lote[:sales_starts_at] && now < lote[:sales_starts_at]
        return Result.err("vendas ainda não começaram")
      end
      if lote[:sales_ends_at] && now > lote[:sales_ends_at]
        return Result.err("vendas encerradas")
      end

      updated = @db[:lotes]
        .where(id: lote_id)
        .where(Sequel[:quantity] >= qty)
        .update(quantity: Sequel[:quantity] - qty)
      return Result.err("esgotado") if updated.zero?

      total = lote[:price_cents] * qty
      id = @db[:pedidos].insert(
        account_id: account_id,
        lote_id: lote_id,
        quantity: qty,
        total_cents: total,
        status: "reserved",
        reserved_until: now + TTL,
        created_at: now
      )
      Result.ok(@db[:pedidos].where(id: id).first)
    end
  end
end
