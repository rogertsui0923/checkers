class MovesController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    move = params[:move]
    prev = @game.moves.order(created_at: :desc).first
    prev_player = prev.current_player
    board = prev.move(move, prev_player)
    @move = Move.create(game: @game, board: board, white_move: !prev.white_move)
    all_valid_moves = @move.all_valid_moves(@move.current_player)
    if move.length == 6
      double_jumps = @move.valid_moves(move[2].to_i, move[3].to_i, prev.current_player)
      if double_jumps.length > 0 && double_jumps[0].length == 6
        @move.update(white_move: prev.white_move)
        all_valid_moves = double_jumps
      end
    end
    ActionCable.server.broadcast "game#{@game.id}", { board: @move.board, player: @move.current_player, moves: all_valid_moves }
  end

  def ai
    create()
    heuristic, ai_move = @move.minimax(@move.board, 'B', 5)
    @new_move = Move.create(game: @game, board: @move.move(ai_move, 'B'), white_move: true)
    ActionCable.server.broadcast "game#{@game.id}", { board: @new_move.board, player: 'W', moves: @new_move.all_valid_moves('W') }
  end
end
