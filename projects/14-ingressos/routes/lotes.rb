# frozen_string_literal: true

class App
  hash_branch "lotes" do |r|
    require_login!

    r.is do
      r.get do
        ds = DB[:lotes]
        ds = ds.where(evento_id: r.params["evento_id"].to_i) if r.params["evento_id"].to_s != ""
        ds.all
      end

      r.post do
        evento_id = r.params["evento_id"].to_i
        name = r.params["name"].to_s.strip
        price = r.params["price_cents"].to_i
        quantity = r.params["quantity"].to_i
        r.halt(422, { "errors" => ["evento_id inválido"] }) unless DB[:eventos].where(id: evento_id).first
        r.halt(422, { "errors" => ["name não pode ficar em branco"] }) if name.empty?
        r.halt(422, { "errors" => ["price_cents deve ser > 0"] }) if price < 1
        r.halt(422, { "errors" => ["quantity deve ser >= 0"] }) if quantity.negative?

        id = DB[:lotes].insert(
          evento_id: evento_id,
          name: name,
          price_cents: price,
          quantity: quantity,
          sales_starts_at: r.params["sales_starts_at"],
          sales_ends_at: r.params["sales_ends_at"]
        )
        created = DB[:lotes].where(id: id).first
        response.status = 201
        response["Location"] = "/lotes/#{id}"
        created
      end
    end

    r.on Integer do |id|
      lote = DB[:lotes].where(id: id).first
      r.halt(404, { "errors" => ["não encontrado"] }) unless lote
      r.get { lote }
    end
  end
end
