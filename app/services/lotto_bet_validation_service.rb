class LottoBetValidationService
    attr_reader :errors

    def initialize(params, client)
      @params = params
      @client = client
      @errors = []
    end

    def validate_create
      validate_numbers
      validate_draw_date
      validate_session
      validate_amount

      {
        valid: @errors.empty?,
        message: @errors.empty? ? nil : "Erreur de validation",
        errors: @errors,
        data: valid_data
      }
    end

    private

    def validate_numbers
      numbers = parse_numbers(@params[:numbers])
      
      if numbers.nil? || numbers.empty?
        @errors << "Numbers can't be blank"
        @errors << "Numbers doit contenir exactement 5 numéros"
        return
      end

      if numbers.length != 5
        @errors << "Numbers doit contenir exactement 5 numéros"
      end

      if numbers.any? { |n| n < 1 || n > 90 }
        @errors << "Les numéros doivent être entre 1 et 90"
      end

      if numbers.uniq.length != numbers.length
        @errors << "Les numéros doivent être uniques"
      end

      @validated_numbers = numbers
    end

    def validate_draw_date
      draw_date = parse_date(@params[:draw_date])
      
      if draw_date.nil?
        @errors << "Draw date is required"
        return
      end

      if draw_date < Date.today
        @errors << "La date de tirage ne peut pas être dans le passé"
      end

      @validated_draw_date = draw_date
    end

    def validate_session
      session = @params[:session]
      
      unless %w[morning evening].include?(session)
        @errors << "Session doit être 'morning' ou 'evening'"
        return
      end

      @validated_session = session
    end

    def validate_amount
      amount = @params[:amount]&.to_d || 100.0
      
      if amount <= 0
        @errors << "Le montant doit être supérieur à 0"
        return
      end

      if @client.client_wallet.real_balance < amount
        @errors << "Solde insuffisant"
      end

      @validated_amount = amount
    end

    def parse_numbers(numbers_param)
      return nil if numbers_param.nil?
      
      return numbers_param.map(&:to_i) if numbers_param.is_a?(Array)
      
      if numbers_param.is_a?(String)
        begin
          parsed = JSON.parse(numbers_param)
          return parsed.map(&:to_i) if parsed.is_a?(Array)
        rescue JSON::ParserError
          return numbers_param.split(',').map(&:strip).map(&:to_i)
        end
      end
      
      nil
    end

    def parse_date(date_param)
      return nil if date_param.nil?
      return date_param if date_param.is_a?(Date)
      
      if date_param.is_a?(String)
        Date.parse(date_param)
      else
        date_param.to_date
      end
    rescue ArgumentError
      nil
    end

    def valid_data
      {
        numbers: @validated_numbers,
        draw_date: @validated_draw_date,
        session: @validated_session,
        amount: @validated_amount
      }
    end
  end

