# frozen_string_literal: true

class App
  hash_branch "eventos" do |r|
    rodauth.require_authentication

    r.is do
      r.get { DB[:eventos].all }

      r.post do
        title = r.params["title"].to_s.strip
        r.halt(422, { "errors" => ["title não pode ficar em branco"] }) if title.empty?

        venue = r.params["venue"].to_s.strip
        id = DB[:eventos].insert(
          title: title,
          venue: (venue.empty? ? nil : venue),
          starts_at: r.params["starts_at"]
        )
        event = DB[:eventos].where(id: id).first
        response.status = 201
        response["Location"] = "/eventos/#{id}"
        event
      end
    end

    r.on Integer do |id|
      event = DB[:eventos].where(id: id).first
      r.halt(404, { "errors" => ["não encontrado"] }) unless event
      r.get { event }
    end
  end
end
