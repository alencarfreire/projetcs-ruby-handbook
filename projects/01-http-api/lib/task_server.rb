# frozen_string_literal: true

require "socket"
require "json"
require_relative "task_store"
require_relative "router"

# HTTP na mão. Sem gem de web.
# No Java o HttpServer do JDK já parseia. No Node, o `http` core também.
# WEBrick saiu da stdlib no Ruby 3 — o que ainda vem é TCPServer + texto.
class TaskServer
  def initialize(host = "127.0.0.1", port = 4567)
    @host = host
    @port = port
    @store = TaskStore.new   # Hash no processo. Mata o server, zerou.
    @router = Router.new(@store)
  end

  def start
    # Escuta TCP. Um request por vez: accept → handle → fecha. Sem thread.
    server = TCPServer.new(@host, @port)
    puts "API em http://#{@host}:#{@port}"
    loop do
      socket = server.accept
      handle(socket)
    end
  ensure
    server.close if server && !server.closed?
  end

  private

  def handle(socket)
    # Primeira linha: "POST /tasks HTTP/1.1"
    request_line = socket.gets
    return if request_line.nil?

    method, raw_path, _ = request_line.split(" ")
    # Query string não é rota. /tasks?x=1 tem que cair em /tasks.
    path = raw_path.to_s.split("?", 2).first
    headers = read_headers(socket)
    body = read_body(socket, headers)

    status, reason, payload, extra = @router.call(method, path, body)
    respond(socket, status, reason, payload, extra)
  rescue JSON::ParserError
    # JSON quebrado é culpa do cliente → 400, não 500.
    respond(socket, 400, "Bad Request", { "error" => "JSON inválido" })
  ensure
    socket.close
  end

  def read_headers(socket)
    # Headers terminam numa linha em branco (\r\n). Até lá, chave: valor.
    headers = {}
    loop do
      line = socket.gets
      break if line.nil? || line == "\r\n" || line == "\n"

      key, value = line.split(":", 2)
      next if key.nil? || value.nil?

      # HTTP trata nome de header como case-insensitive.
      headers[key.strip.downcase] = value.strip
    end
    headers
  end

  def read_body(socket, headers)
    # O tamanho do body está no Content-Length. Não leia até EOF — trava.
    # GET sem body: length 0 → string vazia.
    length = headers["content-length"].to_i
    return "" if length <= 0

    socket.read(length)
  end

  def respond(socket, status, reason, payload, extra = {})
    extra ||= {}
    if payload.nil?
      # 204 Delete: sem body. Content-Length 0. Sem Content-Type de JSON.
      socket.write(
        "HTTP/1.1 #{status} #{reason}\r\n" \
        "Content-Length: 0\r\n" \
        "#{format_extra(extra)}" \
        "Connection: close\r\n" \
        "\r\n"
      )
    else
      body = JSON.generate(payload)
      # bytesize, não length: "ração" tem mais bytes que letras (UTF-8).
      socket.write(
        "HTTP/1.1 #{status} #{reason}\r\n" \
        "Content-Type: application/json\r\n" \
        "Content-Length: #{body.bytesize}\r\n" \
        "#{format_extra(extra)}" \
        "Connection: close\r\n" \
        "\r\n" \
        "#{body}"
      )
    end
  end

  def format_extra(extra)
    extra.map { |key, value| "#{key}: #{value}\r\n" }.join
  end
end
