# frozen_string_literal: true

require "json"
require "securerandom"

class RequestLog
  def initialize(app)
    @app = app
  end

  def call(env)
    t0 = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    request_id = env["HTTP_X_REQUEST_ID"].to_s.strip
    request_id = SecureRandom.uuid if request_id.empty?
    env["ingressos.request_id"] = request_id

    status, headers, body = @app.call(env)
    headers = headers.merge("X-Request-Id" => request_id)
    duration_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - t0) * 1000).round(1)

    $stdout.puts JSON.generate(
      method: env["REQUEST_METHOD"],
      path: env["PATH_INFO"],
      status: status,
      request_id: request_id,
      duration_ms: duration_ms
    )

    [status, headers, body]
  end
end
