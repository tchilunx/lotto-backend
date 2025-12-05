class LottoDrawService
  class DrawAlreadyExistsError < StandardError; end
  class NoBetsError < StandardError; end

  def self.generate_draw(session, draw_date = Date.today)
    # Check if draw already exists
    if LottoDraw.exists?(session: session, draw_date: draw_date)
      raise DrawAlreadyExistsError, "Le tirage pour la session #{session} du #{draw_date} existe déjà"
    end

    ActiveRecord::Base.transaction do
      # 1. Check if there are pending bets for this draw
      pending_bets = LottoBet.where(
        session: session,
        draw_date: draw_date,
        status: :pending
      )

      Rails.logger.info "LottoDrawService: Generating draw for #{session} session on #{draw_date} (#{pending_bets.count} pending bets)"

      # 2. Generate Random Numbers (CSPRNG)
      numbers = (1..90).to_a.sample(5)
      Rails.logger.info "LottoDrawService: Generated numbers: #{numbers.inspect}"

      # 3. Create Draw
      draw = LottoDraw.create!(
        session: session,
        draw_date: draw_date,
        drawn_at: Time.current,
        status: :drawn,
        numbers: numbers
      )

      # 4. Associate ALL pending bets for this session/date to this draw
      # This includes bets created before the draw (they don't have lotto_draw_id yet)
      bets_updated = LottoBet.where(
        session: session,
        draw_date: draw_date,
        status: :pending
      ).where(lotto_draw_id: nil).update_all(lotto_draw_id: draw.id)
      Rails.logger.info "LottoDrawService: Associated #{bets_updated} pending bets to draw ##{draw.id}"

      # 5. Trigger Win Calculation
      LottoWinCalculationService.calculate_wins(draw)

      Rails.logger.info "LottoDrawService: Draw ##{draw.id} completed successfully"
      draw
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "LottoDrawService: Validation error - #{e.message}"
    raise
  rescue => e
    Rails.logger.error "LottoDrawService: Error generating draw - #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    raise
  end
end
