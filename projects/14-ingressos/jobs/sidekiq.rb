# frozen_string_literal: true

require "sidekiq"
require_relative "../db"
require_relative "expire_reservation_job"
require_relative "ingresso_mail_job"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end
