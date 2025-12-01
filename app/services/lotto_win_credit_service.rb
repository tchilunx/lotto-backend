class LottoWinCreditService
  def self.credit_wins(draw)
    wins = LottoWin.where(lotto_draw: draw, status: :pending)
    
    Rails.logger.info "LottoWinCreditService: Crediting #{wins.count} wins for draw ##{draw.id}"
    
    credited_count = 0
    total_credited = 0.0
    
    wins.find_each do |win|
      ActiveRecord::Base.transaction do
        bet = win.lotto_bet
        
        # 1. Consume the stake (burn lock)
        WalletProcessingService.burn_lock!(
          bet.client_wallet,
          bet.amount,
          "STAKE-#{bet.bet_reference}"
        )
        
        # 2. Credit the winnings
        WalletProcessingService.credit!(
          bet.client_wallet,
          win.win_amount,
          "WIN-#{bet.bet_reference}",
          "Gain Lotto #{bet.bet_reference}"
        )
        
        win.update!(status: :credited, credited_at: Time.current)
        
        credited_count += 1
        total_credited += win.win_amount
        
        Rails.logger.info "LottoWinCreditService: Credited #{win.win_amount} to client ##{bet.client_id} (bet ##{bet.id})"
      end
    end
    
    Rails.logger.info "LottoWinCreditService: Completed - Credited #{credited_count} wins, Total: #{total_credited}"
  rescue => e
    Rails.logger.error "LottoWinCreditService: Error crediting wins - #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end

