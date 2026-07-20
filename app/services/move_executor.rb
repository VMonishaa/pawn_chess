class MoveExecutor
  def self.call(game:, color:, from_row:, from_col:, to_row:, to_col:)
    validation = MoveValidator.call(game: game, color: color,
                                    from_row: from_row, from_col: from_col,
                                    to_row: to_row, to_col: to_col)
    return { success: false, error: validation[:error] } unless validation[:valid]

    ActiveRecord::Base.transaction do
      if validation[:action] == :kill
        validation[:victim].captured!
        game.game_players.find_by(color: color).increment!(:captured_pawns)
        game.game_players.find_by(color: opponent(color)).decrement!(:available_pawns)
      end

      validation[:pawn].update!(row: to_row, col: to_col)
      finish_or_switch_turn(game, color, to_row)
    end

    { success: true, action: validation[:action], color: color,
      from: { row: from_row, col: from_col }, to: { row: to_row, col: to_col },
      game_status: game.status, winner: game.winner }
  end

  def self.finish_or_switch_turn(game, color, to_row)
    opp = opponent(color)

    if to_row == MoveValidator::GOAL_ROW[color]
      game.update!(status: :finished, winner: winner_for(game, color))   # win case1 -> goal row
    elsif game.game_players.find_by(color: opp).available_pawns.zero?
      game.update!(status: :finished, winner: winner_for(game, color))   # win case2 -> all captured
    elsif MoveValidator.legal_moves(game, opp).empty?
      game.update!(status: :finished, winner: :draw)                     # draw -> opponent stuck
    else
      game.update!(turn: opp)
    end
  end

  def self.opponent(color)
    color == "white" ? "black" : "white"
  end

  def self.winner_for(game, color)
    color == game.user_color ? :user : :system
  end
end
