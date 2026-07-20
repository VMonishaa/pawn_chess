class SystemTurn

  def self.call(game)
    color = game.user_color == "white" ? "black" : "white"
    return nil unless game.in_progress? && game.turn == color

    move = pick_move(game, color)
    return nil if move.nil?

    MoveExecutor.call(game: game, color: color,from_row: move[:pawn].row, from_col: move[:pawn].col,to_row: move[:to_row], to_col: move[:to_col])
  end

  def self.pick_move(game, color)
    available_moves = MoveValidator.legal_moves(game, color)
    return nil if available_moves.empty?

    opp = color == "white" ? "black" : "white"
    goal = MoveValidator::GOAL_ROW[color]

    winning    = available_moves.select { |m| m[:to_row] == goal }
    safe_kills = available_moves.select { |m| m[:action] == :kill && safe?(game, m, opp) }
    kills      = available_moves.select { |m| m[:action] == :kill }
    safe_moves = available_moves.select { |m| m[:action] == :move && safe?(game, m, opp) }

    best_bucket = [winning, safe_kills, kills, safe_moves, available_moves].find(&:any?)
    best_bucket.min_by{ |m| (m[:to_row] - goal).abs }
  end

  def self.safe?(game, move, enemy_color)
    landing_row = move[:to_row]
    landing_col = move[:to_col]

    enemy_row = landing_row - MoveValidator::DIRECTION[enemy_color]

    left_threat  = MoveValidator.pawn_at(game, enemy_row, landing_col - 1)
    right_threat = MoveValidator.pawn_at(game, enemy_row, landing_col + 1)

    threats = [left_threat, right_threat].compact.select{ |pawn| pawn.color == enemy_color }
    threats.empty?
    end
end
