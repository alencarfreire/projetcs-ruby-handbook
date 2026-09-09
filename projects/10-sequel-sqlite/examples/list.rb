# frozen_string_literal: true

require_relative "../db"

# Dataset → Array de Hash. Sem model.
DB[:eventos].each do |row|
  puts "#{row[:id]}  #{row[:title]}  #{row[:venue]}"
end
