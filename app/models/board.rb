class Board < ApplicationRecord
  belongs_to :game
  has_many :pawns, dependent: :destroy
end
