# frozen_string_literal: true

require "sidekiq"
require_relative "../db"
require_relative "../lib/expire_reservations"

class ExpireReservationJob
  include Sidekiq::Job

  def perform(_pedido_id = nil)
    ExpireReservations.new.call
  end
end
