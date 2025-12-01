class Api::V1::Clients::RegistrationsController < Devise::RegistrationsController
  respond_to :json
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_client!, only: [:create], raise: false

  private

  def sign_up_params
    if params[:client].present?
      super
    else
      params.permit(:email, :password, :password_confirmation, :phone, :first_name, :last_name)
    end
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      # Mettre à jour le jti pour correspondre au token généré
      token = request.env['warden-jwt_auth.token']
      if token.present?
        begin
          decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
          payload = decoded[0]
          resource.update_column(:jti, payload['jti']) if payload['jti'].present?
        rescue => e
          Rails.logger.warn "Failed to update jti: #{e.message}"
        end
      end
      render json: {
        message: 'Signed up successfully.',
        data: resource,
        token: token
      }, status: :ok
    else
      render json: {
        message: "Sign up failed",
        errors: resource.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
end
