class LottoDrawWorker
  include Sidekiq::Worker

  sidekiq_options retry: 3, backtrace: true

  def perform(session = nil)
    # Auto-detect session if not provided
    if session.nil?
      hour = Time.current.hour
      session = hour < 12 ? "morning" : "evening"
    end

    draw_date = Date.today

    Rails.logger.info "LottoDrawWorker: Starting draw generation for #{session} session on #{draw_date}"

    draw = LottoDrawService.generate_draw(session, draw_date)

    Rails.logger.info "LottoDrawWorker: Successfully generated draw ##{draw.id}"
    draw
  rescue LottoDrawService::DrawAlreadyExistsError => e
    Rails.logger.warn "LottoDrawWorker: #{e.message} - Skipping"
    # Don't retry if draw already exists
  rescue => e
    Rails.logger.error "LottoDrawWorker: Failed to generate draw - #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # Re-raise to trigger Sidekiq retry
    raise
  end
end
