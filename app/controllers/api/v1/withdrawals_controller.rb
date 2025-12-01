class Api::V1::WithdrawalsController < Api::V1::ApplicationController
  def index
    meta, @withdrawals = paginate(current_client.service_imoneys.order(created_at: :desc))
    render_success(data: { meta: meta, withdrawals: @withdrawals })
  rescue StandardError => e
    Rails.logger.error("Withdrawals index failed: #{e.class} - #{e.message}")
    render_error(message: "Une erreur est survenue", status: :internal_server_error)
  end

  def create
    # 1. Validation des paramètres
    validation_service = WithdrawalValidationService.new(params, current_client)
    validation_result = validation_service.validate_initiate

    return render_error(
      message: validation_result[:message],
      errors: validation_result[:errors],
      status: :unprocessable_entity
    ) unless validation_result[:valid]

    # 2. Création du draft
    draft_service = WithdrawalDraftCreationService.new(
      current_wallet,
      validation_result[:data],
      current_client
    )

    draft = draft_service.call

    return render_error(
      message: draft_service.error_message,
      status: :unprocessable_entity
    ) unless draft

    # 3. Réponse de succès
    render_success(
      data: { draft_id: draft.id },
      message: "Retrait initié avec succès",
      status: :created
    )
  rescue StandardError => e
    Rails.logger.error("Withdrawal initiation failed: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render_error(
      message: "Une erreur inattendue est survenue",
      status: :internal_server_error
    )
  end

  def confirm
    # 1. Validation des paramètres
    draft_id = params[:draft_id]
    external_reference = params[:external_reference]

    if draft_id.blank?
      return render_error(
        message: "Draft ID est requis",
        status: :unprocessable_entity
      )
    end

    # 2. Confirmation du retrait
    withdrawal = ServiceImoneyService.confirm(draft_id, external_reference)

    # 3. Réponse de succès
    render_success(
      data: withdrawal,
      message: "Retrait complété avec succès"
    )
  rescue ActiveRecord::RecordNotFound
    render_error(message: "Draft non trouvé", status: :not_found)
  rescue => e
    Rails.logger.error("Withdrawal confirmation failed: #{e.class} - #{e.message}")
    render_error(
      message: e.message || "Erreur lors de la confirmation du retrait",
      status: :unprocessable_entity
    )
  end
end
