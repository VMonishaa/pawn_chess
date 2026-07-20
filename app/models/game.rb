class Game < ApplicationRecord
  COLORS = %w[white black].freeze

  enum :status, { in_progress: 0, paused: 1, finished: 2 }
  enum :winner, { system: 0, user: 1, draw: 2 }

  has_one :board, dependent: :destroy
  has_many :game_players, dependent: :destroy
  has_many :players, through: :game_players
  has_many :pawns, through: :board

  validates :turn, :user_color, inclusion: { in: COLORS }
end