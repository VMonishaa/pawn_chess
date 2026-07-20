class MoveValidator
  DIRECTION = { "black" => 1, "white" => -1 }.freeze
  GOAL_ROW  = { "black" => 7, "white" => 0 }.freeze

  def self.call(game:, color:, from_row:, from_col:, to_row:, to_col:)
    return invalid("Game is not accepting moves") unless game.in_progress?
    return invalid("It is not #{color}'s turn") unless game.turn == color

    pawn = pawn_at(game, from_row, from_col)
    unless pawn && pawn.color == color
      return invalid("No available #{color} pawn on the source square")
    end

    check_move_location(game, pawn, to_row, to_col)
  end

  def self.legal_moves(game, color)
    moves = []
    game.pawns.available.where(color: color).find_each do |pawn|
      to_row = pawn.row + DIRECTION[color]
      [0, -1, 1].each do |new_col|
        to_col = pawn.col + new_col
        result = check_move_location(game, pawn, to_row, to_col)
        moves << result.merge(to_row: to_row, to_col: to_col) if result[:valid]
      end
    end
    moves
  end

  def self.check_move_location(game, pawn, to_row, to_col)
    unless to_row.between?(0, 7) && to_col.between?(0, 7)
      return invalid("Destination is off the board")
    end
    unless to_row - pawn.row == DIRECTION[pawn.color]
      return invalid("Pawns move exactly one step forward")
    end

    occupant = pawn_at(game, to_row, to_col)
    case (to_col - pawn.col).abs
    when 0
      occupant ? invalid("Destination square is occupied") : valid(:move, pawn)
    when 1
      if occupant && occupant.color != pawn.color
        valid(:kill, pawn, occupant)
      else
        invalid("Diagonal moves must capture an opponent pawn")
      end
    else
      invalid("Pawns move straight forward or capture one step diagonally")
    end
  end

  def self.pawn_at(game, row, col)
    game.pawns.available.find_by(row: row, col: col)
  end

  def self.valid(action, pawn, victim = nil)
    { valid: true, action: action, pawn: pawn, victim: victim }
  end

  def self.invalid(error)
    { valid: false, error: error }
  end
end
