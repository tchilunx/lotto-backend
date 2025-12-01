class LottoBetService
  class DrawAlreadyCompletedError < StandardError; end
  class BettingClosedError < StandardError; end

  def self.create_bet(client, numbers, session, draw_date, amount = 100.0)
    # 1. Validation closing time (5 min before) - BLOCAGE DES PARIS
    # Les paris sont fermés 5 minutes avant le tirage
    # Draw times: Morning 09:00, Evening 20:25
    draw_time = session == "morning" ? draw_date.to_time.change(hour: 9, min: 0) : draw_date.to_time.change(hour: 21, min: 25)
    closing_time = draw_time - 5.minutes
    if Time.current >= closing_time
      raise BettingClosedError, "Les paris sont fermés pour ce tirage (fermeture à #{closing_time.strftime('%H:%M')}, tirage à #{draw_time.strftime('%H:%M')})"
    end

    # 2. Check if draw already exists and is completed (sécurité supplémentaire)
    existing_draw = LottoDraw.find_by(session: session, draw_date: draw_date)
    if existing_draw&.completed?
      raise DrawAlreadyCompletedError, "Le tirage pour la session #{session} du #{draw_date} a déjà été effectué. Les paris ne sont plus acceptés."
    end

    # 3. KYC Check
    unless client.kyc_requests.approved.exists?
      # Uncomment to enforce KYC
      # raise "KYC requis pour parier" 
    end

    ActiveRecord::Base.transaction do
      # 4. Create Bet (sans lotto_draw_id - sera associé lors du tirage)
      bet = LottoBet.create!(
        client: client,
        client_wallet: client.client_wallet,
        numbers: numbers,
        session: session,
        draw_date: draw_date,
        amount: amount,
        status: :pending,
        bet_reference: "BET-#{SecureRandom.hex(6).upcase}",
        lotto_draw_id: nil  # Sera associé automatiquement lors du tirage
      )

      # 5. Lock funds (Move to theoretical_balance)
      # Using lock! as per plan "Bloquer montant"
      WalletProcessingService.lock!(
        client.client_wallet,
        amount,
        bet.bet_reference,
        "Pari Lotto #{bet.bet_reference}"
      )

      bet
    end
  end
end

