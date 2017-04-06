class Move < ApplicationRecord
  belongs_to :game
  serialize :board

  before_validation :set_defaults

  def set_defaults
    self.board ||= new_board
  end

  def player
    self.white_move ? 'W' : 'B'
  end

  def new_board
    board = []
    odd = false
    for i in 1..8
      row = []
      8.times do
        piece = '-'
        piece = 'b' if (i < 4 && odd)
        piece = 'w' if (i > 5 && odd)
        row.push(piece)
        odd = !odd
      end
      board.push(row)
      odd = !odd
    end
    return board
  end

  def valid_moves(r, c, player, board=self.board)
    moves = []
    piece = board[r][c]
    return moves if piece.upcase != player
    dir = (player == 'W') ? -1 : 1
    is_king = (piece == 'W' || piece == 'B')
    add_move(r, dir, c, 1, player, moves, board)
    add_move(r, dir, c, -1, player, moves, board)
    add_move(r, -dir, c, 1, player, moves, board) if is_king
    add_move(r, -dir, c, -1, player, moves, board) if is_king
    return enforce_jump(moves)
  end

  def all_valid_moves(player, board=self.board)
    moves = []
    (0..7).each do |r|
      (0..7).each { |c| moves.concat(valid_moves(r, c, player, board)) }
    end
    return enforce_jump(moves)
  end

  def add_move(r, r_step, c, c_step, player, moves, board=self.board)
    new_r = r + r_step
    new_c = c + c_step
    return if (new_r < 0 || new_r > 7 || new_c < 0 || new_c > 7)
    target = board[new_r][new_c]
    return if target.upcase == player
    return moves.push("#{r}#{c}#{new_r}#{new_c}") if target == '-'

    jump_r = new_r + r_step
    jump_c = new_c + c_step
    return if (jump_r < 0 || jump_r > 7 || jump_c < 0 || jump_c > 7)
    target = board[jump_r][jump_c]
    moves.push("#{r}#{c}#{jump_r}#{jump_c}#{new_r}#{new_c}") if target == '-'
  end

  def enforce_jump(moves)
    jumps = moves.select { |move| move.length == 6 }
    return jumps if jumps.length > 0
    return moves
  end

  def move(m, player, board=self.board)
    valid = false
    all_valid_moves(player, board).each { |move| valid = true if move == m }
    return if !valid

    updated_board = Marshal.load(Marshal.dump(board))
    r, c, new_r, new_c, eat_r, eat_c = m.split('').map { |e| e.to_i }

    piece = updated_board[r][c]
    piece.upcase! if (player == 'W' && new_r == 0) || (player == 'B' && new_r == 7)
    updated_board[r][c] = '-'
    updated_board[new_r][new_c] = piece
    updated_board[eat_r][eat_c] = '-' if m.length == 6
    return updated_board
  end

  def jumps(r, c, player, board=self.board)
    return valid_moves(r, c, player, board).select { |move| move.length == 6 }
  end

  def display(board=self.board)
    puts '    0  1  2  3  4  5  6  7 '
    board.each_with_index do |row, i|
      print " #{i} "
      row.each { |piece| print " #{piece} " }
      puts ''
    end
    return
  end

  def count(piece, board=self.board)
    n = 0
    board.each { |row| row.each { |p| n += 1 if p == piece } }
    return n
  end

  def heuristic(board=self.board)
    return (
      count('b', board) + 2 * count('B', board) -
      count('w', board) - 2 * count('W', board)
    )
  end

  def minimax(board, player, depth, piece=nil)
    return [heuristic(board), nil] if depth == 0
    moves = []
    if piece
      moves = jumps(piece[0].to_i, piece[1].to_i, player, board)
    else
      moves = all_valid_moves(player, board)
    end
    return [heuristic(board), nil] if moves.length == 0
    is_self = (player == 'B')
    must_jump = (moves[0].length == 6)

    extreme = is_self ? -999999 : 999999
    best_move = nil
    moves.each do |m|
      next_board = move(m, player, board)
      next_piece = nil
      next_player = player == 'B' ? 'W' : 'B'
      next_moves = jumps(m[2].to_i, m[3].to_i, player, next_board) if must_jump
      if (must_jump && next_moves.length > 0)
        next_piece = m[2..4]
        next_player = player
      end
      h, next_move = minimax(next_board, next_player, depth - 1, next_piece)
      # p '      ' * (5-depth) + m + '       ' + h.to_s + player
      if (is_self && h > extreme) || (!is_self && h < extreme)
        extreme = h
        best_move = m
      end
    end
    return [extreme, best_move]
  end



  def minimaxWithBugs(board, player, depth, piece=nil)
    return [heuristic(board), nil] if depth == 0

    moves = all_valid_moves(player, board)
    moves = valid_moves(piece[0].to_i, piece[1].to_i, player, board) if piece
    return [heuristic(board), nil] if moves.length == 0
    is_self = (player == 'B')
    must_jump = (moves[0].length == 6)

    extreme = is_self ? -999999 : 999999
    best_move = nil
    moves.each do |m|
      next_board = move(m, player, board)
      next_piece = nil
      next_player = player == 'B' ? 'W' : 'B'
      next_moves = valid_moves(m[2].to_i, m[3].to_i, player, next_board) if must_jump
      if (must_jump && next_moves.length > 0 && next_moves[0].length == 6)
        next_piece = m[2..4]
        next_player = player
      end
      h, next_move = minimaxWithBugs(next_board, next_player, depth - 1, next_piece)
      if (is_self && h > extreme) || (!is_self && h < extreme)
        extreme = h
        best_move = m
      end
    end
    return [extreme, best_move]
  end

end
