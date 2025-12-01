class LottoBetCreationService
  attr_reader :error_message

  def initialize(client, validated_data)
    @client = client
    @numbers = validated_data[:numbers]
    @draw_date = validated_data[:draw_date]
    @session = validated_data[:session]
    @amount = validated_data[:amount]
    @error_message = nil
  end

  def call
    bet = LottoBetService.create_bet(
      @client,
      @numbers,
      @session,
      @draw_date,
      @amount
    )
    
    bet
  rescue LottoBetService::DrawAlreadyCompletedError => e
    @error_message = e.message
    nil
  rescue LottoBetService::BettingClosedError => e
    @error_message = e.message
    nil
  rescue ActiveRecord::RecordInvalid => e
    @error_message = "Erreur de validation"
    @validation_errors = e.record.errors.full_messages
    nil
  rescue => e
    Rails.logger.error("LottoBetCreationService error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    @error_message = "Une erreur est survenue lors de la création du pari"
    nil
  end
end

