# frozen_string_literal: true

require "sidekiq"
require_relative "../db"
require_relative "../lib/ingresso_mail"

class IngressoMailJob
  include Sidekiq::Job

  def perform(pedido_id)
    pedido = DB[:pedidos].where(id: pedido_id, status: "paid").first
    return unless pedido

    IngressoMail.new.entregar(pedido)
  end
end
