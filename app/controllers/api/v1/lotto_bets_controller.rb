class Api::V1::LottoBetsController < Api::V1::ApplicationController
  def index
    meta, @bets = paginate(current_client.lotto_bets.order(created_at: :desc))
    render_success(data: { meta: meta, data: @bets })
  end

  def create
    # 1. Validation des paramètres
    validation_service = LottoBetValidationService.new(bet_params, current_client)
    validation_result = validation_service.validate_create

    return render_error(
      message: validation_result[:message],
      errors: validation_result[:errors],
      status: :unprocessable_entity
    ) unless validation_result[:valid]

    # 2. Création du pari
    creation_service = LottoBetCreationService.new(
      current_client,
      validation_result[:data]
    )

    bet = creation_service.call

    return render_error(
      message: creation_service.error_message,
      status: :unprocessable_entity
    ) unless bet

    # 3. Réponse de succès
    render_success(
      data: { bet: bet },
      message: "Pari créé avec succès"
    )
  end

  def show
    bet = current_client.lotto_bets.find(params[:id])
    render_success(data: bet)
  rescue ActiveRecord::RecordNotFound
    render_error(message: "Pari non trouvé", status: :not_found)
  end

  private

  def bet_params
    params.require(:lotto_bet).permit(:session, :draw_date, :amount, numbers: [])
  rescue ActionController::ParameterMissing
    params.permit(:session, :draw_date, :amount, numbers: [])
  end
end
