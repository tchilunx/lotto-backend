class ServiceImoneyService
  def self.initiate(client, amount, phone_number, draft_data = {})
    if client.client_wallet.real_balance < amount
      raise WalletProcessingService::InsufficientFundsError, "Solde insuffisant pour le retrait"
    end

    ServiceImoneyDraft.create!(
      client: client,
      amount: amount,
      phone_number: phone_number,
      draft_data: draft_data
    )
  end

  def self.confirm(draft_id, external_reference)
    draft = ServiceImoneyDraft.find(draft_id)

    ActiveRecord::Base.transaction do
      withdrawal = ServiceImoney.create!(
        client: draft.client,
        amount: draft.amount,
        phone_number: draft.phone_number,
        status: :completed,
        reference: "WITHDRAW-#{SecureRandom.hex(8).upcase}",
        external_reference: external_reference
      )

      WalletProcessingService.debit!(
        draft.client.client_wallet,
        draft.amount,
        withdrawal.reference,
        "Withdrawal to #{draft.phone_number}"
      )

      draft.destroy
      withdrawal
    end
  end
end
