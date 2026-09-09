# frozen_string_literal: true

require "stringio"

class RawBody
  def initialize(app)
    @app = app
  end

  def call(env)
    if env["PATH_INFO"].to_s.start_with?("/webhooks")
      input = env["rack.input"]
      body = input.read
      input.rewind if input.respond_to?(:rewind)
      env["RAW_BODY"] = body
      env["rack.input"] = StringIO.new(body)
    end
    @app.call(env)
  end
end
