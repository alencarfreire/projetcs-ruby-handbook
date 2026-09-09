# frozen_string_literal: true

require "openssl"

module Hmac
  module_function

  def sign(secret, body)
    OpenSSL::HMAC.hexdigest("SHA256", secret, body)
  end

  def valid?(secret, body, signature)
    expected = sign(secret, body)
    return false if signature.to_s.empty?
    return false if expected.bytesize != signature.bytesize

    OpenSSL.fixed_length_secure_compare(expected, signature)
  end
end
