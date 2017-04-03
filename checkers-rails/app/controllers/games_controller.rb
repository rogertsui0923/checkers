class GamesController < ApplicationController
  def index
    render json: Game.all.map { |g| g.id }

  end

  def create
    @game = Game.new(black_id: params[:black_id], white_id: params[:white_id])
    @game.save
    @move = Move.new(game: @game, white_move: true)
    @move.save
    render json: { game: @game.id, board: @move.board, player: @move.current_player, moves: @move.all_valid_moves(@move.current_player) }
  end

  def show
    @game = Game.find(params[:id])
    @move = @game.moves.order(created_at: :desc).first
    render json: { board: @move.board, player: @move.current_player, moves: @move.all_valid_moves(@move.current_player) }
  end

end
