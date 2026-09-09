# frozen_string_literal: true

require "roda"
require "json"
require "rodauth"
require_relative "db"

SECRET = "dev_secret_ingressos_nao_usar_em_producao_0123456789abcdef"

# Arquitetura A: um app.rb, um db.rb. Dataset Hash. Rodauth JWT.
class App < Roda
  plugin :json
  plugin :json_parser
  plugin :halt
  plugin :rodauth, json: :only do
    enable :create_account, :login, :logout, :jwt
    hmac_secret SECRET
    jwt_secret SECRET
    account_password_hash_column :password_hash
    require_password_confirmation? false
    require_login_confirmation? false
    already_logged_in { request.halt }
  end

  route do |r|
    r.root do
      { "name" => "ingressos-pragmatic" }
    end

    r.rodauth

    r.on "eventos" do
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
end
