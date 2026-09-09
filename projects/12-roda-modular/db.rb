# frozen_string_literal: true

require "sequel"

DIR = File.expand_path("storage", __dir__)
Dir.mkdir(DIR) unless Dir.exist?(DIR)

DB = Sequel.sqlite(File.join(DIR, "app.sqlite3"))
