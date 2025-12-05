class Api::V1::WalletsController < Api::V1::ApplicationController
  def show
    wallet = current_wallet
    render_success(data: wallet)
  end

  def balance
    wallet = current_wallet
    
    render_success(data: {
      balance: wallet.real_balance,
      real_balance: wallet.real_balance,
      theoretical_balance: wallet.theoretical_balance,
      currency: "FCFA"
    })
  end

  def operations
    meta, @operations = paginate(current_client.client_operations.order(created_at: :desc))
    render_success(data: { meta: meta, operations: @operations })
  end
end
