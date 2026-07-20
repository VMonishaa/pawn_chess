class GamePlayer < ApplicationRecord
  belongs_to :game
  belongs_to :player
  has_many :pawns, dependent: :destroy

  validates :color, inclusion: { in: Game::COLORS }
  validates :color, uniqueness: { scope: :game_id }
end