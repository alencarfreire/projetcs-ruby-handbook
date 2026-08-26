# frozen_string_literal: true

require "socket"
require "json"
require_relative "task_store"
require_relative "router"

# TCPServer + texto HTTP. Sem gem de web.
class TaskServer
  def initialize(host = "127.0.0.1", port = 4567)
    @host = host
    @port = port
    @store = TaskStore.new
    @router = Router.new(@store)
  end

  def start
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
    request_line = socket.gets
    return if request_line.nil?

    method, raw_path, _ = request_line.split(" ")
    path = raw_path.to_s.split("?", 2).first
    headers = read_headers(socket)
    body = read_body(socket, headers)

    status, reason, payload, extra = @router.call(method, path, body)
    respond(socket, status, reason, payload, extra)
  rescue JSON::ParserError
    respond(socket, 400, "Bad Request", { "error" => "JSON inválido" })
  ensure
    socket.close
  end

  def read_headers(socket)
    headers = {}
    loop do
      line = socket.gets
      break if line.nil? || line == "\r\n" || line == "\n"

      key, value = line.split(":", 2)
      next if key.nil? || value.nil?

      headers[key.strip.downcase] = value.strip
    end
    headers
  end

  def read_body(socket, headers)
    length = headers["content-length"].to_i
    return "" if length <= 0

    socket.read(length)
  end

  def respond(socket, status, reason, payload, extra = {})
    extra ||= {}
    if payload.nil?
      socket.write(
        "HTTP/1.1 #{status} #{reason}\r\n" \
        "Content-Length: 0\r\n" \
        "#{format_extra(extra)}" \
        "Connection: close\r\n" \
        "\r\n"
      )
    else
      body = JSON.generate(payload)
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
