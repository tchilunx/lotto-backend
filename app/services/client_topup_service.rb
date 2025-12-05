class ClientTopupService
  def self.initiate(client, amount, payment_method, draft_data = {})
    ClientTopupDraft.create!(
      client: client,
      amount: amount,
      payment_method: payment_method,
      draft_data: draft_data
    )
  end

  def self.confirm(draft_id, external_reference, client)
    draft = ClientTopupDraft.find(draft_id)
    ensure_draft_owner!(draft, client)

    ActiveRecord::Base.transaction do
      topup = ClientTopup.create!(
        client: draft.client,
        amount: draft.amount,
        payment_method: draft.payment_method,
        status: :completed,
        reference: "TOPUP-#{SecureRandom.hex(8).upcase}",
        external_reference: external_reference
      )

      WalletProcessingService.credit!(
        draft.client.client_wallet,
        draft.amount,
        topup.reference,
        "Topup via #{draft.payment_method}"
      )

      draft.destroy
      topup
    end
  end

  def self.ensure_draft_owner!(draft, client)
    return if client.nil?
    return if draft.client_id == client.id

    raise ActiveRecord::RecordNotFound, "Draft not found"
  end
end
