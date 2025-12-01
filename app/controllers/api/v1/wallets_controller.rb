class Api::V1::WalletsController < Api::V1::ApplicationController
  def show
    wallet = current_wallet
    render_success(data: wallet)
  rescue StandardError => e
    Rails.logger.error("Wallet show failed: #{e.class} - #{e.message}")
    render_error(message: "Une erreur est survenue", status: :internal_server_error)
  end

  def balance
    wallet = current_wallet
    
    render_success(data: {
      balance: wallet.real_balance,
      real_balance: wallet.real_balance,
      theoretical_balance: wallet.theoretical_balance,
      currency: "FCFA"
    })
  rescue StandardError => e
    Rails.logger.error("Wallet balance failed: #{e.class} - #{e.message}")
    render_error(message: "Une erreur est survenue", status: :internal_server_error)
  end

  def operations
    meta, @operations = paginate(current_client.client_operations.order(created_at: :desc))
    render_success(data: { meta: meta, operations: @operations })
  rescue StandardError => e
    Rails.logger.error("Wallet operations failed: #{e.class} - #{e.message}")
    render_error(message: "Une erreur est survenue", status: :internal_server_error)
  end
end
