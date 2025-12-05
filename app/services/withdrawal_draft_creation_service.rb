class WithdrawalDraftCreationService
    attr_reader :error_message

    def initialize(wallet, validated_data, client)
      @wallet = wallet
      @amount = validated_data[:amount]
      @phone_number = validated_data[:phone_number]
      @draft_data = validated_data[:draft_data]
      @client = client
      @error_message = nil
    end

    def call
      draft = ServiceImoneyService.initiate(
        @client,
        @amount,
        @phone_number,
        @draft_data
      )

      draft
    rescue WalletProcessingService::InsufficientFundsError => e
      @error_message = e.message
      nil
    rescue => e
      Rails.logger.error("WithdrawalDraftCreationService error: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      @error_message = "Erreur lors de l'initiation du retrait: #{e.message}"
      nil
    end
end
