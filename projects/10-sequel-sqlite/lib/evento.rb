# frozen_string_literal: true

require_relative "../db"

# Opcional neste recorte. Dataset já devolve Hash.
# Model existe para o capítulo 10.5 contrastar.
class Evento < Sequel::Model(DB[:eventos])
end
