class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.integer :status, default: 0, null: false
      t.string :turn, default: "white", null: false
      t.string :user_color, null: false
      t.integer :winner

      t.timestamps
    end
  end
end
