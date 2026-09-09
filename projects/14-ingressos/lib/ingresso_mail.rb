# frozen_string_literal: true

require "fileutils"

class IngressoMail
  def initialize(root: File.expand_path("..", __dir__))
    @dir = File.join(root, "tmp/mails")
  end

  def entregar(pedido)
    FileUtils.mkdir_p(@dir)
    path = File.join(@dir, "pedido-#{pedido[:id]}.txt")
    File.write(path, <<~TXT)
      Ingresso confirmado
      pedido=#{pedido[:id]}
      lote=#{pedido[:lote_id]}
      quantity=#{pedido[:quantity]}
      total_cents=#{pedido[:total_cents]}
    TXT
    path
  end
end
