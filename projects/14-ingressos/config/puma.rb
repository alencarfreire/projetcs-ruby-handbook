# frozen_string_literal: true

port = ENV.fetch("PORT", "9292")
bind "tcp://0.0.0.0:#{port}"
environment ENV.fetch("RACK_ENV", "development")
threads_count = Integer(ENV.fetch("PUMA_THREADS", "3"))
threads threads_count, threads_count
workers_count = Integer(ENV.fetch("WEB_CONCURRENCY", "0"))
workers workers_count if workers_count.positive?
