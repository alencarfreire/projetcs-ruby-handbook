# frozen_string_literal: true

# Você é o router. Sem routes.rb, sem @GetMapping, sem app.get.
# Cada ramo devolve [status, reason, payload, headers_extra].
# payload nil = sem body (204).
class Router
  def initialize(store)
    @store = store
  end

  def call(method, path, body)
    if path == "/tasks"
      # Coleção: listar e criar. PUT/PATCH/DELETE aqui → 405, não 404.
      case method
      when "GET" then [200, "OK", @store.all, {}]
      when "POST" then @store.create(body)
      else
        [405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, POST" }]
      end
    elsif (match = path.match(%r{\A/tasks/(\d+)\z}))
      # Membro: só dígitos. /tasks/abc não casa → cai no 404 de baixo.
      id = Integer(match[1])
      case method
      when "GET" then @store.show(id)
      when "PUT" then @store.replace(id, body)   # substitui title + completed
      when "PATCH" then @store.patch(id, body)   # só o que veio
      when "DELETE" then @store.delete(id)
      else
        # POST /tasks/1 é 405: o path existe como membro, o verbo não.
        [405, "Method Not Allowed", { "error" => "método não permitido" }, { "Allow" => "GET, PUT, PATCH, DELETE" }]
      end
    else
      [404, "Not Found", { "error" => "não encontrado" }, {}]
    end
  end
end
