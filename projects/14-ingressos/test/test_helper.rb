# frozen_string_literal: true

ENV["RACK_ENV"] = "test"
storage = File.expand_path("../storage", __dir__)
Dir.mkdir(storage) unless Dir.exist?(storage)
ENV["DATABASE_URL"] = File.join(storage, "test.sqlite3")
ENV.delete("REDIS_URL")
ENV.delete("SIDEKIQ")

require "minitest/autorun"
require "rack/test"
require "json"
require "sequel"

require_relative "../db"

Sequel.extension :migration
Sequel::Migrator.run(DB, File.expand_path("../migrate", __dir__))

require_relative "../lib/raw_body"
require_relative "../lib/request_log"
require_relative "../app"
require_relative "../lib/hmac"
require_relative "../lib/env"

class IngressosTest < Minitest::Test
  include Rack::Test::Methods

  def app
    RequestLog.new(RawBody.new(App.app))
  end

  def setup
    DB[:jwt_denylist].delete
    DB[:webhook_events].delete
    DB[:pedidos].delete
    DB[:lotes].delete
    DB[:eventos].delete
    DB[:locais].delete
    DB[:accounts].delete
  end

  def json
    JSON.parse(last_response.body)
  end

  def auth_json
    { "CONTENT_TYPE" => "application/json", "HTTP_ACCEPT" => "application/json" }
  end

  def login!(email: "joao@email.com", password: "senha123")
    post "/create-account", JSON.generate(login: email, password: password), auth_json
    post "/login", JSON.generate(login: email, password: password), auth_json
    header "Authorization", last_response.headers["Authorization"]
    header "Accept", "application/json"
  end

  def seed_lote!(quantity: 2)
    login!
    post "/eventos", JSON.generate(title: "Sunset Jazz", venue: "Sala 2"), auth_json
    evento_id = json["id"]
    post "/lotes", JSON.generate(
      evento_id: evento_id,
      name: "Pista",
      price_cents: 8000,
      quantity: quantity
    ), auth_json
    json["id"]
  end
end
