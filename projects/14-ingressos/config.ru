# frozen_string_literal: true

require_relative "app"
require_relative "lib/raw_body"
require_relative "lib/request_log"

run RequestLog.new(RawBody.new(App.freeze.app))
