class LottoDrawCreationService
  attr_reader :error_message

  def initialize(session, draw_date = Date.today)
    @session = session
    @draw_date = draw_date
    @error_message = nil
  end

  def call
    draw = LottoDrawService.generate_draw(@session, @draw_date)
    draw
  rescue LottoDrawService::DrawAlreadyExistsError => e
    @error_message = e.message
    nil
  rescue => e
    Rails.logger.error("LottoDrawCreationService error: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    @error_message = "Erreur lors de la création du tirage: #{e.message}"
    nil
  end
end

