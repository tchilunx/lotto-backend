class Api::V1::LottoWinsController < Api::V1::ApplicationController
  def index
    meta, @wins = paginate(LottoWin.joins(:lotto_bet).where(lotto_bets: { client_id: current_client.id }).order(created_at: :desc))
    render json: { meta: meta, data: @wins }
  end
end
