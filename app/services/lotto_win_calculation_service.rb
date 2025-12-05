class LottoWinCalculationService
  def self.calculate_wins(draw)
    # Find all bets for this draw (either by lotto_draw_id or by session/date)
    bets = LottoBet.where(
      lotto_draw_id: draw.id,
      status: :pending
    )

    # Fallback: if no bets found by draw_id, try by session and date
    if bets.empty?
      bets = LottoBet.where(
        session: draw.session,
        draw_date: draw.draw_date,
        status: :pending
      )
      # Associate them to the draw
      bets.update_all(lotto_draw_id: draw.id) if bets.any?
    end

    Rails.logger.info "LottoWinCalculationService: Calculating wins for draw ##{draw.id} (#{bets.count} bets)"

    wins_count = 0
    losses_count = 0
    total_win_amount = 0.0

    bets.find_each do |bet|
      matches = (bet.numbers & draw.numbers).length
      win_amount = calculate_win_amount(matches, bet.amount)

      ActiveRecord::Base.transaction do
        if win_amount > 0
          bet.update!(status: :won)
          LottoWin.create!(
            lotto_bet: bet,
            lotto_draw: draw,
            win_amount: win_amount,
            matched_numbers: matches,
            status: :pending
          )
          wins_count += 1
          total_win_amount += win_amount
          Rails.logger.info "LottoWinCalculationService: Bet ##{bet.id} won! Matches: #{matches}, Amount: #{win_amount}"
        else
          bet.update!(status: :lost)
          WalletProcessingService.burn_lock!(
            bet.client_wallet,
            bet.amount,
            "LOSS-#{bet.bet_reference}"
          )
          losses_count += 1
        end
      end
    end

    draw.update!(status: :completed)

    Rails.logger.info "LottoWinCalculationService: Draw ##{draw.id} completed - Wins: #{wins_count}, Losses: #{losses_count}, Total win amount: #{total_win_amount}"

    # Enqueue credit worker (5 minutes delay)
    LottoWinCreditWorker.perform_in(5.minutes, draw.id)
    Rails.logger.info "LottoWinCalculationService: Scheduled credit worker for draw ##{draw.id} in 5 minutes"
  rescue => e
    Rails.logger.error "LottoWinCalculationService: Error calculating wins - #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end

  def self.calculate_win_amount(matches, stake)
    case matches
    when 2 then stake * 2
    when 3 then stake * 20
    when 4 then stake * 500
    when 5 then stake * 10000
    else 0
    end
  end
end
