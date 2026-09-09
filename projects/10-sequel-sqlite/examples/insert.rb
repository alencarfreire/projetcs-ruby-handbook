# frozen_string_literal: true

require_relative "../db"

id = DB[:eventos].insert(title: "Noite Ruby", venue: "Auditório", starts_at: Time.new(2026, 12, 1, 19, 0, 0))
row = DB[:eventos].where(id: id).first
p row
