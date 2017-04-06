class MovesController < ApplicationController
  # @game is the current game instance
  # @prev is the previous move instance
  # @move is the current move instance
  # @m is the move string from @prev to @move, r, c, new_r, new_c, eat_r, eat_c
  # @jumps is an array of moves if multiple jumps are possible
  # more_jumps must return true to use @jumps

  def initialize_variables
    @game = Game.find(params[:game_id])
    @prev = @game.moves.order(created_at: :desc).first
    @m = params[:move]
  end

  def create_move(board, white_move)
    Move.create(game: @game, board: board, white_move: white_move)
  end

  def broadcast(board, player, moves)
    ActionCable.server.broadcast "game#{@game.id}", {
      board: board,
      player: player,
      moves: moves
    }
  end

  def create_move_and_check_jumps
    @move = create_move(@prev.move(@m, @prev.player), !@prev.white_move)
    moves = @move.all_valid_moves(@move.player)

    jumps = @move.jumps(@m[2].to_i, @m[3].to_i, @prev.player)
    has_further_jumps = (@m.length == 6 && jumps.length > 0)
    if has_further_jumps
      @move.update(white_move: @prev.white_move)
      moves = jumps
    end

    broadcast(@move.board, @move.player, moves)
    return has_further_jumps
  end

  def create
    initialize_variables()
    create_move_and_check_jumps()
  end

  def ai
    create()
    return if @move.white_move

    piece = nil
    loop do
      @prev = @move
      heuristic, @m = @prev.minimax(@prev.board, @prev.player, 5, piece)
      break if !create_move_and_check_jumps()
      piece = @m[2..3]
    end
  end
end
