class GameRestarter
  def self.call(game)
    ActiveRecord::Base.transaction do
      game.board.pawns.delete_all
      game.game_players.update_all(available_pawns: 8, captured_pawns: 0)
      game.update!(status: :in_progress, turn: "white", winner: nil)

      { "black" => 0, "white" => 7 }.each do |color, row|
        game_player = game.game_players.find_by(color: color)
        8.times do |col|
          Pawn.create!(board: game.board, game_player: game_player, color: color, row: row, col: col)
        end
      end
    end
    game
  end
end
