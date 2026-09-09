# frozen_string_literal: true

require "sequel"

url = ENV["DATABASE_URL"].to_s

DB = if url.start_with?("postgres")
  Sequel.connect(url)
else
  dir = File.expand_path("storage", __dir__)
  Dir.mkdir(dir) unless Dir.exist?(dir)
  path = url.empty? ? File.join(dir, "app.sqlite3") : url.sub(%r{\Asqlite://}, "")
  path = File.join(dir, "app.sqlite3") if path.empty?
  Sequel.sqlite(path)
end
