# frozen_string_literal: true

class App
  hash_branch "locais" do |r|
    rodauth.require_authentication

    r.is do
      r.get { DB[:locais].all }

      r.post do
        name = r.params["name"].to_s.strip
        r.halt(422, { "errors" => ["name não pode ficar em branco"] }) if name.empty?

        id = DB[:locais].insert(name: name)
        local = DB[:locais].where(id: id).first
        response.status = 201
        response["Location"] = "/locais/#{id}"
        local
      end
    end

    r.on Integer do |id|
      local = DB[:locais].where(id: id).first
      r.halt(404, { "errors" => ["não encontrado"] }) unless local
      r.get { local }
    end
  end
end
