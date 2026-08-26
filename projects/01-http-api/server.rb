# frozen_string_literal: true

require "socket"
require "json"

class TaskServer
  def initialize(host = "127.0.0.1", port = 4567)
    @host = host
    @port = port
    @tasks = {}
    @next_id = 1
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

    status, reason, payload, extra = dispatch(method, path, body)
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

  def dispatch(method, path, body)
    if path == "/tasks"
      case method
      when "GET" then [200, "OK", @tasks.values, {}]
      when "POST" then create_task(body)
      else
        [405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, POST" }]
      end
    elsif (match = path.match(%r{\A/tasks/(\d+)\z}))
      id = Integer(match[1])
      case method
      when "GET" then show_task(id)
      when "PUT" then replace_task(id, body)
      when "PATCH" then patch_task(id, body)
      when "DELETE" then delete_task(id)
      else
        [405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, PUT, PATCH, DELETE" }]
      end
    else
      [404, "Not Found", { "error" => "não encontrado" }, {}]
    end
  end

  def create_task(body)
    data = parse_object(body)
    title_error = require_title(data)
    return title_error if title_error

    completed_error = optional_completed(data)
    return completed_error if completed_error

    id = @next_id
    @next_id += 1
    task = {
      "id" => id,
      "title" => data["title"],
      "completed" => data.key?("completed") ? data["completed"] : false
    }
    @tasks[id] = task
    [201, "Created", task, { "Location" => "/tasks/#{id}" }]
  end

  def show_task(id)
    task = @tasks[id]
    return not_found if task.nil?

    [200, "OK", task, {}]
  end

  def replace_task(id, body)
    return not_found unless @tasks.key?(id)

    data = parse_object(body)
    title_error = require_title(data)
    return title_error if title_error
    return missing_completed unless data.key?("completed")

    completed_error = boolean_completed(data["completed"])
    return completed_error if completed_error

    task = {
      "id" => id,
      "title" => data["title"],
      "completed" => data["completed"]
    }
    @tasks[id] = task
    [200, "OK", task, {}]
  end

  def patch_task(id, body)
    task = @tasks[id]
    return not_found if task.nil?

    data = parse_object(body)
    if data.key?("title")
      title_error = require_title(data)
      return title_error if title_error
    end
    if data.key?("completed")
      completed_error = boolean_completed(data["completed"])
      return completed_error if completed_error
    end

    task["title"] = data["title"] if data.key?("title")
    task["completed"] = data["completed"] if data.key?("completed")
    [200, "OK", task, {}]
  end

  def delete_task(id)
    return not_found unless @tasks.key?(id)

    @tasks.delete(id)
    [204, "No Content", nil, {}]
  end

  def parse_object(body)
    raise JSON::ParserError if body.nil? || body.strip.empty?

    data = JSON.parse(body)
    raise JSON::ParserError unless data.is_a?(Hash)

    data
  end

  def require_title(data)
    title = data["title"]
    return nil if title.is_a?(String) && !title.strip.empty?

    [400, "Bad Request", { "error" => "title é obrigatório" }, {}]
  end

  def optional_completed(data)
    return nil unless data.key?("completed")

    boolean_completed(data["completed"])
  end

  def boolean_completed(value)
    return nil if [true, false].include?(value)

    [400, "Bad Request", { "error" => "completed deve ser boolean" }, {}]
  end

  def missing_completed
    [400, "Bad Request", { "error" => "completed é obrigatório" }, {}]
  end

  def not_found
    [404, "Not Found", { "error" => "não encontrado" }, {}]
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

TaskServer.new.start if $PROGRAM_NAME == __FILE__
