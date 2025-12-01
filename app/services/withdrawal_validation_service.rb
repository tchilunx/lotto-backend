class WithdrawalValidationService
    attr_reader :errors

    def initialize(params, client)
      @params = params
      @client = client
      @errors = []
    end

    def validate_initiate
      validate_amount
      validate_phone_number
      validate_balance

      {
        valid: @errors.empty?,
        message: @errors.empty? ? nil : "Erreur de validation",
        errors: @errors,
        data: valid_data
      }
    end

    private

    def validate_amount
      amount = @params[:amount]&.to_d

      if amount.nil? || amount <= 0
        @errors << "Le montant doit être supérieur à 0"
        return
      end

      @validated_amount = amount
    end

    def validate_phone_number
      phone_number = @params[:phone_number]

      if phone_number.blank?
        @errors << "Le numéro de téléphone est requis"
        return
      end

      @validated_phone_number = phone_number
    end

    def validate_balance
      return unless @validated_amount

      if @client.client_wallet.real_balance < @validated_amount
        @errors << "Solde insuffisant"
      end
    end

    def valid_data
      {
        amount: @validated_amount,
        phone_number: @validated_phone_number,
        draft_data: @params[:draft_data] || {}
      }
    end
  end
