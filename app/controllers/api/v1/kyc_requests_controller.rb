class Api::V1::KycRequestsController < Api::V1::ApplicationController
  def create
    # 1. Validation des paramètres
    if kyc_params[:document_type].blank?
      return render_error(
        message: "Le type de document est requis",
        status: :unprocessable_entity
      )
    end

    if kyc_params[:document_number].blank?
      return render_error(
        message: "Le numéro de document est requis",
        status: :unprocessable_entity
      )
    end

    # 2. Création de la demande KYC
    kyc = current_client.kyc_requests.create!(kyc_params)

    # 3. Réponse de succès
    render_success(
      data: kyc,
      message: "Demande KYC soumise avec succès",
      status: :created
    )
  rescue ActiveRecord::RecordInvalid => e
    render_error(
      message: "Erreur de validation",
      errors: e.record.errors.full_messages,
      status: :unprocessable_entity
    )
  end

  def show_by_client
    meta, @kycs = paginate(current_client.kyc_requests.order(created_at: :desc))
    render_success(data: { meta: meta, kycs: @kycs })
  end

  private

  def kyc_params
    params.permit(:document_type, :document_number, documents: [])
  end
end
