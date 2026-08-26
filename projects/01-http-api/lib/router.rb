# frozen_string_literal: true

# Você é o router: method + path. Sem routes.rb.
class Router
  def initialize(store)
    @store = store
  end

  def call(method, path, body)
    if path == "/tasks"
      case method
      when "GET" then [200, "OK", @store.all, {}]
      when "POST" then @store.create(body)
      else
        [405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, POST" }]
      end
    elsif (match = path.match(%r{\A/tasks/(\d+)\z}))
      id = Integer(match[1])
      case method
      when "GET" then @store.show(id)
      when "PUT" then @store.replace(id, body)
      when "PATCH" then @store.patch(id, body)
      when "DELETE" then @store.delete(id)
      else
        [405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, PUT, PATCH, DELETE" }]
      end
    else
      [404, "Not Found", { "error" => "não encontrado" }, {}]
    end
  end
end
