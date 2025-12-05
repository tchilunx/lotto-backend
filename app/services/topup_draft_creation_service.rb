class TopupDraftCreationService
    attr_reader :error_message

    def initialize(wallet, validated_data, client)
      @wallet = wallet
      @amount = validated_data[:amount]
      @payment_method = validated_data[:payment_method]
      @draft_data = validated_data[:draft_data]
      @client = client
      @error_message = nil
    end

    def call
      draft = ClientTopupService.initiate(
        @client,
        @amount,
        @payment_method,
        @draft_data
      )

      draft
    rescue => e
      Rails.logger.error("TopupDraftCreationService error: #{e.class} - #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      @error_message = "Erreur lors de l'initiation du topup: #{e.message}"
      nil
    end
end
