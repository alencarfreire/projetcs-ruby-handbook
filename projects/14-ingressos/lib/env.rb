# frozen_string_literal: true

module IngressosEnv
  module_function

  def rack_env
    ENV["RACK_ENV"].to_s
  end

  def production?
    rack_env == "production"
  end

  def jwt_secret
    secret = ENV["JWT_SECRET"].to_s
    if production? && secret.empty?
      abort "JWT_SECRET obrigatório em production"
    end
    secret.empty? ? "dev_jwt_ingressos_nao_usar_em_producao_0123456789abcdef" : secret
  end

  def webhook_secret
    secret = ENV["WEBHOOK_SECRET"].to_s
    if production? && secret.empty?
      abort "WEBHOOK_SECRET obrigatório em production"
    end
    secret.empty? ? "dev_webhook_ingressos_nao_usar_em_producao" : secret
  end
end
