class LottoWinCreditWorker
  include Sidekiq::Worker

  sidekiq_options retry: 5, backtrace: true

  def perform(draw_id)
    draw = LottoDraw.find(draw_id)
    
    Rails.logger.info "LottoWinCreditWorker: Starting credit process for draw ##{draw_id}"
    
    LottoWinCreditService.credit_wins(draw)
    
    Rails.logger.info "LottoWinCreditWorker: Successfully credited wins for draw ##{draw_id}"
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "LottoWinCreditWorker: Draw ##{draw_id} not found - #{e.message}"
    # Don't retry if draw doesn't exist
  rescue => e
    Rails.logger.error "LottoWinCreditWorker: Failed to credit wins - #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # Re-raise to trigger Sidekiq retry
    raise
  end
end

