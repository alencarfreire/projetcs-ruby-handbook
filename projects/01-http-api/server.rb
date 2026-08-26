# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "task_server"

TaskServer.new.start if $PROGRAM_NAME == __FILE__
