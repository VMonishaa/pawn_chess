# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_20_053339) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "boards", force: :cascade do |t|
    t.integer "columns", default: 8, null: false
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.integer "rows", default: 8, null: false
    t.datetime "updated_at", null: false
    t.index ["game_id"], name: "index_boards_on_game_id", unique: true
  end

  create_table "game_players", force: :cascade do |t|
    t.integer "available_pawns", default: 8, null: false
    t.integer "captured_pawns", default: 0, null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.bigint "game_id", null: false
    t.bigint "player_id", null: false
    t.datetime "updated_at", null: false
    t.index ["game_id", "color"], name: "index_game_players_on_game_id_and_color", unique: true
    t.index ["game_id", "player_id"], name: "index_game_players_on_game_id_and_player_id", unique: true
    t.index ["game_id"], name: "index_game_players_on_game_id"
    t.index ["player_id"], name: "index_game_players_on_player_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "status", default: 0, null: false
    t.string "turn", default: "white", null: false
    t.datetime "updated_at", null: false
    t.string "user_color", null: false
    t.integer "winner"
  end

  create_table "pawns", force: :cascade do |t|
    t.bigint "board_id", null: false
    t.integer "col", null: false
    t.string "color", null: false
    t.datetime "created_at", null: false
    t.bigint "game_player_id", null: false
    t.integer "row", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["board_id", "row", "col"], name: "index_pawns_on_board_id_and_row_and_col"
    t.index ["board_id"], name: "index_pawns_on_board_id"
    t.index ["game_player_id"], name: "index_pawns_on_game_player_id"
  end

  create_table "players", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "type", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "boards", "games"
  add_foreign_key "game_players", "games"
  add_foreign_key "game_players", "players"
  add_foreign_key "pawns", "boards"
  add_foreign_key "pawns", "game_players"
end
