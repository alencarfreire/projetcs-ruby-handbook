# frozen_string_literal: true

require "json"

# Banco de bolso. Igual um List no handler Java: vive no processo.
# Diferente do PHP, que zera o array no fim do request.
# Diferente do Rails, que é tabela. Ctrl+C → Hash novo, next_id volta a 1.
class TaskStore
  def initialize
    @tasks = {}   # chave Integer (id) → Hash com chaves string
    @next_id = 1  # autoincrement. Você gera. O cliente não escolhe na URL.
  end

  def all
    @tasks.values
  end

  def find(id)
    @tasks[id]
  end

  def create(body)
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
      # JSON.parse devolve string nas chaves. :title aqui seria nil.
      "completed" => data.key?("completed") ? data["completed"] : false
    }
    @tasks[id] = task
    # 201 + Location: o recurso nasceu. 200 seria "já existia".
    [201, "Created", task, { "Location" => "/tasks/#{id}" }]
  end

  def show(id)
    task = @tasks[id]
    return not_found if task.nil?

    [200, "OK", task, {}]
  end

  def replace(id, body)
    # PUT manda o recurso inteiro. Sem title ou sem completed → 400.
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

  def patch(id, body)
    # PATCH mescla. Rails junta PUT e PATCH no update — aqui você distingue.
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

    # key?, não `if data["completed"]` — false é valor, não ausência.
    task["title"] = data["title"] if data.key?("title")
    task["completed"] = data["completed"] if data.key?("completed")
    [200, "OK", task, {}]
  end

  def delete(id)
    return not_found unless @tasks.key?(id)

    @tasks.delete(id)
    # 204: apagou. Sem body. 200 com {} também "funciona" — entrevista puxa 204.
    [204, "No Content", nil, {}]
  end

  private

  def parse_object(body)
    # Body vazio ou "{quebrado" → ParserError → 400 no TaskServer.
    raise JSON::ParserError if body.nil? || body.strip.empty?

    data = JSON.parse(body)
    # Lista (`[{...}]`) não é um recurso. GET /tasks que devolve Array.
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
end
