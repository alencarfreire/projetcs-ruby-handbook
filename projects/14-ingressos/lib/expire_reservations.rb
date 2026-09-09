# frozen_string_literal: true

# Devolve estoque de pedidos reserved cujo relógio passou. Idempotente.
class ExpireReservations
  def initialize(db: DB)
    @db = db
  end

  def call(now: Time.now)
    expired = 0
    @db.transaction do
      @db[:pedidos].where(status: "reserved").where { reserved_until < now }.each do |pedido|
        n = @db[:pedidos].where(id: pedido[:id], status: "reserved").update(status: "expired")
        next if n.zero?

        @db[:lotes].where(id: pedido[:lote_id]).update(quantity: Sequel[:quantity] + pedido[:quantity])
        expired += 1
      end
    end
    expired
  end
end
