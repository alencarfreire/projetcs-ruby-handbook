class ApplicationController < ActionController::API
  include Payloads

  before_action :require_login

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def current_user
    return @current_user if defined?(@current_user)

    token = bearer_token
    @current_user = token.present? ? User.find_by(api_token: token) : nil
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    render json: { errors: ["token ausente ou inválido"] }, status: :unauthorized
  end

  def bearer_token
    header = request.headers["Authorization"].to_s
    return if header.blank?

    scheme, token = header.split(" ", 2)
    return unless scheme&.casecmp("Bearer")&.zero?

    token.presence
  end

  def render_not_found
    render json: { errors: ["não encontrado"] }, status: :not_found
  end

  def render_errors(record, status: :unprocessable_entity)
    render json: { errors: record.errors.full_messages }, status: status
  end
end
