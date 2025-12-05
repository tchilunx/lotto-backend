class Api::V1::Clients::ClientsController < Api::V1::ApplicationController
  def wallet
    # 1. Récupération du wallet
    wallet = current_wallet
    
    return render_error(
      message: 'Le portefeuille du client n\'a pas été trouvé',
      status: :not_found
    ) if wallet.nil?

    # 2. Préparation des données
    wallet_data = {
      client_wallet: {
        id: wallet.id,
        wallet_type: wallet.wallet_type,
        real_balance: wallet.real_balance,
        theoretical_balance: wallet.theoretical_balance,
        locked: wallet.locked,
        created_at: wallet.created_at,
        updated_at: wallet.updated_at
      },
      real_balance: wallet.real_balance,
      currency: "FCFA"
    }

    # 3. Réponse de succès
    render_success(data: wallet_data)
  end
end

