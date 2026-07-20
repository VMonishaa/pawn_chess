class GameSerializer
  def self.call(game)
    
    board = []
    8.times do
      row = [nil, nil, nil, nil, nil, nil, nil, nil]
      board << row
    end

    game.pawns.available.each do |pawn|
      board[pawn.row][pawn.col] = pawn.color
    end

    board_display = board.map do |row|
      row.map{ |cell| cell.nil? ? "." : cell[0].upcase }.join(" ")
    end

    {
      id: game.id,
      status: game.status,
      turn: game.turn,
      user_color: game.user_color,
      winner: game.winner,
      players: game.game_players.map do |gp|
        { color: gp.color, available_pawns: gp.available_pawns, captured_pawns: gp.captured_pawns }
      end,
      board: board,
      board_display: board_display
    }
  end
end
