class Api::V1::Clients::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_client!, only: [:create], raise: false

  def create
    phone = sign_in_params[:phone]
    password = sign_in_params[:password]
    
    Rails.logger.debug "Attempting login with phone: #{phone}"
    
    client = Client.find_for_database_authentication(phone: phone)
    
    if client && client.valid_password?(password)
      sign_in(client)
      # Mettre à jour le jti pour correspondre au token généré
      # Cela permet de valider le token lors des prochaines requêtes
      token = request.env['warden-jwt_auth.token']
      if token.present?
        begin
          decoded = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: 'HS256' })
          payload = decoded[0]
          client.update_column(:jti, payload['jti']) if payload['jti'].present?
        rescue => e
          Rails.logger.warn "Failed to update jti: #{e.message}"
        end
      end
      respond_with(client)
    else
      Rails.logger.warn "Authentication failed for phone: #{phone}"
      render json: { error: 'Unauthorized', message: 'Invalid phone or password.' }, status: :unauthorized
    end
  rescue => e
    Rails.logger.error "Login error: #{e.class} - #{e.message}"
    render json: { error: 'Unauthorized', message: 'Invalid phone or password.' }, status: :unauthorized
  end

  private

  def sign_in_params
    if params[:client].present?
      params.require(:client).permit(:phone, :password)
    else
      params.permit(:phone, :password)
    end
  end

  def respond_with(resource, _opts = {})
    render json: {
      message: 'Connexion réussie.',
      data: resource,
      token: request.env['warden-jwt_auth.token']
    }, status: :ok
  end

  def respond_to_on_destroy
    if current_client
      render json: { message: "Logged out successfully" }, status: :ok
    else
      render json: { message: "Couldn't find an active session." }, status: :unauthorized
    end
  end
end
