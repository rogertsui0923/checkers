class Board
  # A board is a 2-dimensional array of characters.
  # 'w' represents a regular white piece, 'b' a regular black piece.
  # 'W' represents a white king, 'B' a black king.
  # '-' represents an empty square.
  # The player is represented as either 'W' or 'B'.

  attr_accessor :board
  attr_accessor :player

  def initialize()
    @board = new_board()
    @player = 'W'
  end

  def new_board()
    board = [];
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

  def piece(row, col)
    return @board[row][col]
  end

  def is_empty(row, col)
    return piece(row, col) == '-'
  end

  def is_king(row, col)
    return false if is_empty(row, col)
    return piece(row, col).upcase == piece(row, col)
  end

  # returns '-' if the square is empty
  def player(row, col)
    return piece(row, col).upcase
  end

  def direction(player)
    return (player == 'W') ? -1 : 1
  end

  def valid_moves(row, col, player)
    moves = []
    return moves if piece(row, col).upcase != player
    dir = direction(player)
    add_move(row, dir, col, 1, player, moves)
    add_move(row, dir, col, -1, player, moves)
    add_move(row, -dir, col, 1, player, moves) if is_king(row, col)
    add_move(row, -dir, col, -1, player, moves) if is_king(row, col)
    return enforce_jump(moves)
  end

  def all_valid_moves(player)
    moves = []
    (0..7).each do |r|
      (0..7).each do |c|
        moves.concat(valid_moves(r, c, player))
      end
    end
    return enforce_jump(moves)
  end

  # row_step and col_step can be 1 or -1
  def add_move(row, row_step, col, col_step, player, moves)
    new_row = row + row_step
    new_col = col + col_step
    return if (new_row < 0 || new_row > 7 || new_col < 0 || new_col > 7)
    target = @board[new_row][new_col]
    return if target.upcase == player
    return moves.push([row, col, new_row, new_col]) if target == '-'

    jump_row = new_row + row_step
    jump_col = new_col + col_step
    return if (jump_row < 0 || jump_row > 7 || jump_col < 0 || jump_col > 7)
    if @board[jump_row][jump_col] == '-'
      moves.push([row, col, jump_row, jump_col, new_row, new_col])
    end
  end

  def enforce_jump(moves)
    jumps = []
    moves.each do |move|
      jumps.push(move) if move.length == 6
    end
    return jumps if jumps.length > 0
    return moves
  end

  def move(row, col, new_row, new_col, player)
    correct_move = []
    valid_moves(row, col, player).each do |move|
      correct_move = move if (new_row == move[2] && new_col == move[3])
    end
    return if correct_move == []
    piece = @board[row][col]
    if (player == 'W' && new_row == 7) || (player == 'B' && new_row == 0)
      piece.capitalize!
    end
    @board[row][col] = '-'
    @board[new_row][new_col] = piece
    if correct_move.length == 6
      @board[correct_move[4]][correct_move[5]] = '-'
    end
    display()
  end

  def display()
    puts '    0  1  2  3  4  5  6  7 '
    @board.each_with_index do |row, i|
      print " #{i} "
      row.each do |piece|
        print " #{piece} "
      end
      puts ''
    end
    return
  end

  def play()
  end
end
