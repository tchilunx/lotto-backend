class LottoDrawQueryService
    def initialize(params = {})
      @params = params
    end

    def list
      scope = LottoDraw.where(status: [:drawn, :completed])
      
      scope = apply_filters(scope)
      
      scope.order(draw_date: :desc, session: :desc)
    end

    def latest
      LottoDraw.where(status: [:drawn, :completed])
               .order(draw_date: :desc, session: :desc)
               .first
    end

    def find_with_stats(id)
      draw = LottoDraw.find(id)
      
      stats = {
        total_bets: draw.lotto_bets.count,
        winning_bets: draw.lotto_bets.where(status: :won).count,
        losing_bets: draw.lotto_bets.where(status: :lost).count,
        total_wins: draw.lotto_wins.sum(:win_amount),
        total_wins_count: draw.lotto_wins.count
      }
      
      {
        draw: draw,
        statistics: stats
      }
    end

    def bets_for_draw(draw_id, current_client = nil)
      draw = LottoDraw.find(draw_id)
      
      bets_scope = draw.lotto_bets.order(created_at: :desc)
      
      bets_scope = bets_scope.where(status: @params[:status]) if @params[:status].present?
      bets_scope = bets_scope.where(client_id: current_client.id) if current_client.present?
      
      {
        draw: draw,
        bets: bets_scope
      }
    end

    private

    def apply_filters(scope)
      scope = scope.where(session: @params[:session]) if @params[:session].present?
      
      if @params[:start_date].present?
        scope = scope.where("draw_date >= ?", Date.parse(@params[:start_date]))
      end
      
      if @params[:end_date].present?
        scope = scope.where("draw_date <= ?", Date.parse(@params[:end_date]))
      end
      
      scope
    end
end

