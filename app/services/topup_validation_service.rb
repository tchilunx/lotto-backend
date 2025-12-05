class TopupValidationService
    attr_reader :errors

    def initialize(params, client)
      @params = params
      @client = client
      @errors = []
    end

    def validate_initiate
      validate_amount
      validate_payment_method

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

    def validate_payment_method
      payment_method = @params[:payment_method]

      if payment_method.blank?
        @errors << "Le mode de paiement est requis"
        return
      end

      @validated_payment_method = payment_method
    end

    def valid_data
      {
        amount: @validated_amount,
        payment_method: @validated_payment_method,
        draft_data: @params[:draft_data] || {}
      }
    end
end
