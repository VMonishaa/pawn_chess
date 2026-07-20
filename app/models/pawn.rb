class Pawn < ApplicationRecord
  enum :status, { available: 0, captured: 1 }

  belongs_to :board
  belongs_to :game_player

  validates :color, inclusion: { in: Game::COLORS }
  validates :row, :col, numericality: {
    only_integer: true, greater_than_or_equal_to: 0, less_than: 8
  }
end
