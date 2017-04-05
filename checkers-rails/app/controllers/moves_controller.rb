class MovesController < ApplicationController
  def create
    @game = Game.find(params[:game_id])
    move = params[:move]
    prev = @game.moves.order(created_at: :desc).first
    prev_player = prev.current_player
    board = prev.move(move, prev_player)
    @move = Move.create(game: @game, board: board, white_move: !prev.white_move)
    all_valid_moves = @move.all_valid_moves(@move.current_player)
    @has_more_jumps = false
    if move.length == 6
      double_jumps = @move.valid_moves(move[2].to_i, move[3].to_i, prev.current_player)
      if double_jumps.length > 0 && double_jumps[0].length == 6
        @has_more_jumps = true
        @move.update(white_move: prev.white_move)
        all_valid_moves = double_jumps
      end
    end
    ActionCable.server.broadcast "game#{@game.id}", { board: @move.board, player: @move.current_player, moves: all_valid_moves }
  end

  def ai
    create()
    return if @has_more_jumps

    current_piece = nil
    loop do
      heuristic, ai_move = @move.minimax(@move.board, 'B', 5, current_piece)
      new_board = @move.move(ai_move, 'B')
      @new_move = Move.create(game: @game, board: new_board, white_move: true)
      ai_has_more_jumps = false
      if ai_move.length == 6
        double_jumps = @new_move.valid_moves(ai_move[2].to_i, ai_move[3].to_i, 'B')
        if double_jumps.length > 0 && double_jumps[0].length == 6
          ai_has_more_jumps = true
          @new_move.update(white_move: false)
          current_piece = ai_move[2..3]
        end
      end
      if !ai_has_more_jumps
        ActionCable.server.broadcast "game#{@game.id}", { board: @new_move.board, player: 'W', moves: @new_move.all_valid_moves('W') }
        break
      else
        ActionCable.server.broadcast "game#{@game.id}", { board: @new_move.board, player: 'B', moves: [] }
      end
      @move = @new_move

    end
  end
end
