class CreatePawns < ActiveRecord::Migration[8.1]
  def change
    create_table :pawns do |t|
      t.references :board, null: false, foreign_key: true
      t.references :game_player, null: false, foreign_key: true
      t.string :color, null: false
      t.integer :row, null: false
      t.integer :col, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :pawns, [:board_id, :row, :col]
  end
end
