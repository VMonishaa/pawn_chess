class CreateBoards < ActiveRecord::Migration[8.1]
  def change
    create_table :boards do |t|
      t.references :game, null: false, foreign_key: true, index: {unique: true}
      t.integer :rows, default: 8, null: false
      t.integer :columns, default: 8, null: false

      t.timestamps
    end
  end
end
