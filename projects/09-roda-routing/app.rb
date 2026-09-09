# frozen_string_literal: true

require "roda"
require "json"

# Recorte: árvore de rotas. Eventos num Hash no processo.
# Mata o Puma, zerou. Sem Sequel, sem Rodauth, sem lote.
class App < Roda
  plugin :json
  plugin :json_parser
  plugin :halt

  EVENTS = {}
  NEXT_ID = [1]

  route do |r|
    r.root do
      { "name" => "ingressos-routing" }
    end

    r.on "eventos" do
      r.is do
        r.get { EVENTS.values }

        r.post do
          title = r.params["title"].to_s.strip
          r.halt(422, { "errors" => ["title não pode ficar em branco"] }) if title.empty?

          id = NEXT_ID[0]
          NEXT_ID[0] += 1
          venue = r.params["venue"].to_s.strip
          event = {
            "id" => id,
            "title" => title,
            "venue" => (venue.empty? ? nil : venue)
          }
          EVENTS[id] = event
          response.status = 201
          response["Location"] = "/eventos/#{id}"
          event
        end
      end

      r.on Integer do |id|
        event = EVENTS[id]
        r.halt(404, { "errors" => ["não encontrado"] }) unless event

        r.get { event }
      end
    end
  end
end
