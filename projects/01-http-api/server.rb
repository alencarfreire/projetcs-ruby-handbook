# frozen_string_literal: true

# Ponto de entrada. `ruby server.rb` cai aqui.
# Coloca lib/ no $LOAD_PATH e sobe o TCPServer.
# Se este arquivo for só `require` (bin/server), o `if` embaixo não dispara.

$LOAD_PATH.unshift(File.expand_path("lib", __dir__))
require "task_server"

TaskServer.new.start if $PROGRAM_NAME == __FILE__
