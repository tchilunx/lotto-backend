class Api::V1::LottoDrawsController < Api::V1::ApplicationController
  skip_before_action :authenticate_client!, only: [:index, :show, :latest]

  def index
    # 1. Récupération des tirages avec filtres
    query_service = LottoDrawQueryService.new(params)
    draws = query_service.list

    # 2. Pagination
    meta, @draws = paginate(draws)

    # 3. Réponse
    render_success(data: { meta: meta, draws: @draws })
  rescue StandardError => e
    Rails.logger.error("LottoDraws index failed: #{e.class} - #{e.message}")
    render_error(message: "Une erreur est survenue", status: :internal_server_error)
  end

  def latest
    # 1. Récupération du dernier tirage
    query_service = LottoDrawQueryService.new
    draw = query_service.latest

    # 2. Vérification
    return render_error(message: "Aucun tirage trouvé", status: :not_found) unless draw

    # 3. Réponse
    render_success(data: draw)
  rescue StandardError => e
    Rails.logger.error("LottoDraws latest failed: #{e.class} - #{e.message}")
    render_error(message: "Une erreur est survenue", status: :internal_server_error)
  end

  def show
    # 1. Récupération du tirage avec statistiques
    query_service = LottoDrawQueryService.new(params)
    result = query_service.find_with_stats(params[:id])

    # 2. Préparation de la réponse
    response_data = {
      draw: result[:draw],
      statistics: result[:statistics]
    }

    # 3. Inclusion des paris si demandé
    if params[:include_bets] == 'true' || params[:include_bets] == '1'
      bets_scope = result[:draw].lotto_bets.order(created_at: :desc)
      bets_scope = bets_scope.where(status: params[:bet_status]) if params[:bet_status].present?
      
      meta, bets = paginate(bets_scope)
      response_data[:bets] = {
        meta: meta,
        data: bets
      }
    end

    # 4. Réponse
    render_success(data: response_data)
  rescue ActiveRecord::RecordNotFound
    render_error(message: "Tirage non trouvé", status: :not_found)
  rescue StandardError => e
    Rails.logger.error("LottoDraws show failed: #{e.class} - #{e.message}")
    render_error(message: "Une erreur est survenue", status: :internal_server_error)
  end

  def bets
    # 1. Récupération des paris du tirage
    query_service = LottoDrawQueryService.new(params)
    result = query_service.bets_for_draw(params[:id], current_client)

    # 2. Pagination
    meta, @bets = paginate(result[:bets])

    # 3. Réponse
    render_success(data: {
      draw_id: result[:draw].id,
      draw_date: result[:draw].draw_date,
      session: result[:draw].session,
      numbers: result[:draw].numbers,
      meta: meta,
      bets: @bets
    })
  rescue ActiveRecord::RecordNotFound
    render_error(message: "Tirage non trouvé", status: :not_found)
  rescue StandardError => e
    Rails.logger.error("LottoDraws bets failed: #{e.class} - #{e.message}")
    render_error(message: "Une erreur est survenue", status: :internal_server_error)
  end

  def create
    # 1. Validation des paramètres
    session = draw_params[:session]
    draw_date = draw_params[:draw_date] || Date.today

    unless %w[morning evening].include?(session)
      return render_error(
        message: "Session invalide",
        errors: ["Session doit être 'morning' ou 'evening'"],
        status: :unprocessable_entity
      )
    end

    # 2. Création du tirage
    creation_service = LottoDrawCreationService.new(session, draw_date)
    draw = creation_service.call

    return render_error(
      message: creation_service.error_message,
      status: :unprocessable_entity
    ) unless draw

    # 3. Réponse de succès
    render_success(
      data: draw,
      message: "Tirage créé avec succès",
      status: :created
    )
  rescue StandardError => e
    Rails.logger.error("LottoDraws create failed: #{e.class} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    render_error(
      message: "Une erreur inattendue est survenue",
      status: :internal_server_error
    )
  end

  private

  def draw_params
    params.permit(:session, :draw_date)
  end
end
