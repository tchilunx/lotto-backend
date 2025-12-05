class Api::V1::ApplicationController < ActionController::API
  before_action :log_auth_headers, if: -> { Rails.env.development? }
  before_action :authenticate_client!
  before_action :set_default_response_format
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from StandardError, with: :handle_error

  # Pagination helper
  def paginate(collection, items: 20)
    page = params[:page]&.to_i || 1
    page = 1 if page < 1
    per_page = [params[:per_page]&.to_i || items, 100].min # Max 100 items per page
    per_page = 1 if per_page < 1
    
    total_count = collection.count
    total_pages = (total_count.to_f / per_page).ceil
    total_pages = 1 if total_pages < 1
    
    paginated_collection = collection.offset((page - 1) * per_page).limit(per_page)
    
    meta = {
      current_page: page,
      per_page: per_page,
      total_pages: total_pages,
      total_count: total_count,
      next_page: page < total_pages ? page + 1 : nil,
      prev_page: page > 1 ? page - 1 : nil
    }
    
    [meta, paginated_collection]
  end

  # Helper pour formater les réponses de succès
  def render_success(data: nil, message: nil, status: :ok)
    response = {}
    response[:message] = message if message.present?
    response[:data] = data if data.present?
    render json: response, status: status
  end

  # Helper pour formater les erreurs
  def render_error(message:, errors: nil, status: :unprocessable_entity)
    response = { error: message }
    response[:errors] = errors if errors.present?
    render json: response, status: status
  end

  # Helper pour obtenir le wallet du client actuel
  def current_wallet
    @current_wallet ||= current_client.client_wallet
  end

  private

  def log_auth_headers
    auth_header = request.headers['Authorization']
    Rails.logger.debug "=== AUTH DEBUG ==="
    Rails.logger.debug "Authorization header: #{auth_header.inspect}"
    Rails.logger.debug "Request headers: #{request.headers.to_h.select { |k, v| k.downcase.include?('auth') || k.downcase.include?('authorization') }.inspect}"
    Rails.logger.debug "Current client before auth: #{current_client.inspect}"
    Rails.logger.debug "=================="
  end

  def set_default_response_format
    request.format = :json
  end

  def not_found
    render_error(message: 'Ressource non trouvée', status: :not_found)
  end

  def bad_request(exception)
    render_error(message: exception.message, status: :bad_request)
  end

  def handle_error(exception)
    controller_name = self.class.name
    
    Rails.logger.error "=" * 50
    Rails.logger.error "#{controller_name}##{action_name} failed: #{exception.class} - #{exception.message}"
    Rails.logger.error exception.backtrace.join("\n")
    Rails.logger.error "=" * 50
    
    render_error(
      message: Rails.env.development? ? exception.message : 'Une erreur est survenue',
      status: :internal_server_error
    )
  end
end
