# frozen_string_literal: true

# `ruby server.rb` — coloca lib/ no path e sobe. bin/server faz require daqui.
$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "task_server"

TaskServer.new.start if $PROGRAM_NAME == __FILE__
