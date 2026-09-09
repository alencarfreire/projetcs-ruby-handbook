# frozen_string_literal: true

Result = Struct.new(:ok?, :value, :errors, keyword_init: true) do
  def self.ok(value)
    new(ok?: true, value: value, errors: [])
  end

  def self.err(errors)
    new(ok?: false, value: nil, errors: Array(errors))
  end
end
