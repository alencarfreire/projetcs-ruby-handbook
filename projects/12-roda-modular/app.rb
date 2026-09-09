# frozen_string_literal: true

require "roda"
require "json"
require "rodauth"
require_relative "db"

SECRET = "dev_secret_ingressos_nao_usar_em_producao_0123456789abcdef"

# Arquitetura B: app.rb orquestra. Ramos em routes/.
class App < Roda
  plugin :json
  plugin :json_parser
  plugin :halt
  plugin :hash_routes
  plugin :rodauth, json: :only do
    enable :create_account, :login, :logout, :jwt
    hmac_secret SECRET
    jwt_secret SECRET
    account_password_hash_column :password_hash
    require_password_confirmation? false
    require_login_confirmation? false
    already_logged_in { request.halt }
  end
end

require_relative "routes/eventos"
require_relative "routes/locais"

class App
  route do |r|
    r.root do
      { "name" => "ingressos-modular" }
    end

    r.rodauth
    r.hash_routes
  end
end
