# frozen_string_literal: true

require "roda"
require "json"
require "rodauth"
require "digest"
require_relative "db"
require_relative "lib/env"

SECRET = IngressosEnv.jwt_secret

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
    after_logout do
      raw = request.env["HTTP_AUTHORIZATION"].to_s
      next if raw.empty?

      begin
        DB[:jwt_denylist].insert(fingerprint: Digest::SHA256.hexdigest(raw), revoked_at: Time.now)
      rescue Sequel::UniqueConstraintViolation
        nil
      end
    end
  end

  def require_login!
    rodauth.require_authentication
    raw = request.env["HTTP_AUTHORIZATION"].to_s
    return if raw.empty?

    fp = Digest::SHA256.hexdigest(raw)
    request.halt(401, { "error" => "token revogado" }) if DB[:jwt_denylist].where(fingerprint: fp).first
  end
end

require_relative "routes/eventos"
require_relative "routes/locais"
require_relative "routes/lotes"
require_relative "routes/pedidos"
require_relative "routes/pagamentos"
require_relative "routes/webhooks"

class App
  route do |r|
    r.root do
      { "name" => "ingressos" }
    end

    r.is "up" do
      DB.test_connection
      { "ok" => true }
    end

    r.rodauth
    r.hash_routes
  end
end
