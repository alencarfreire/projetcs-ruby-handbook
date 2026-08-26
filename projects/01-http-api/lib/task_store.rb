# frozen_string_literal: true

require "json"

# Banco de bolso: Hash no processo. Mata o servidor, zerou.
class TaskStore
  def initialize
    @tasks = {}
    @next_id = 1
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
      "completed" => data.key?("completed") ? data["completed"] : false
    }
    @tasks[id] = task
    [201, "Created", task, { "Location" => "/tasks/#{id}" }]
  end

  def show(id)
    task = @tasks[id]
    return not_found if task.nil?

    [200, "OK", task, {}]
  end

  def replace(id, body)
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

  def delete(id)
    return not_found unless @tasks.key?(id)

    @tasks.delete(id)
    [204, "No Content", nil, {}]
  end

  private

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
end
