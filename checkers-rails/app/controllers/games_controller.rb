class GamesController < ApplicationController
  def index
    render json: Game.order(created_at: :desc).map { |g| g.id }
  end

  def create
    @game = Game.create(black_id: params[:black_id], white_id: params[:white_id])
    @move = Move.create(game: @game, white_move: true)
    render_game_data()
  end

  def show
    @game = Game.find(params[:id])
    @move = @game.moves.order(created_at: :desc).first
    render_game_data()
  end

  def render_game_data
    render json: {
      game: @game.id,
      board: @move.board,
      player: @move.current_player,
      moves: @move.all_valid_moves(@move.current_player)
    }
  end

end
