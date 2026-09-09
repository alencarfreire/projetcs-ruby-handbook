# frozen_string_literal: true

require_relative "../lib/reservar_lote"
require_relative "../lib/sidekiq_optional"

class App
  hash_branch "pedidos" do |r|
    require_login!

    r.is do
      r.get { DB[:pedidos].where(account_id: rodauth.session_value).all }

      r.post do
        result = ReservarLote.new.call(
          account_id: rodauth.session_value,
          lote_id: r.params["lote_id"],
          quantity: r.params["quantity"]
        )
        r.halt(422, { "errors" => result.errors }) unless result.ok?

        pedido = result.value
        SidekiqOptional.enqueue_expire(pedido[:id], pedido[:reserved_until])
        response.status = 201
        response["Location"] = "/pedidos/#{pedido[:id]}"
        pedido
      end
    end

    r.on Integer do |id|
      pedido = DB[:pedidos].where(id: id, account_id: rodauth.session_value).first
      r.halt(404, { "errors" => ["não encontrado"] }) unless pedido
      r.get { pedido }
    end
  end
end
