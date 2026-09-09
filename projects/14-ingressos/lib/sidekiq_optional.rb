# frozen_string_literal: true

module SidekiqOptional
  module_function

  def enabled?
    !ENV["REDIS_URL"].to_s.empty? || ENV["SIDEKIQ"] == "1"
  end

  def enqueue_expire(pedido_id, at)
    return unless enabled?

    require_relative "../jobs/expire_reservation_job"
    ExpireReservationJob.perform_at(at, pedido_id)
  end

  def enqueue_mail(pedido_id)
    return unless enabled?

    require_relative "../jobs/ingresso_mail_job"
    IngressoMailJob.perform_async(pedido_id)
  end
end
