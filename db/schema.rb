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

ActiveRecord::Schema[8.1].define(version: 2026_06_05_222010) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "anime_genres", force: :cascade do |t|
    t.bigint "anime_id", null: false
    t.datetime "created_at", null: false
    t.bigint "genre_id", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id"], name: "index_anime_genres_on_anime_id"
    t.index ["genre_id"], name: "index_anime_genres_on_genre_id"
  end

  create_table "anime_studios", force: :cascade do |t|
    t.bigint "anime_id", null: false
    t.datetime "created_at", null: false
    t.bigint "studio_id", null: false
    t.datetime "updated_at", null: false
    t.index ["anime_id"], name: "index_anime_studios_on_anime_id"
    t.index ["studio_id"], name: "index_anime_studios_on_studio_id"
  end

  create_table "animes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "episodes"
    t.string "image_url"
    t.integer "mal_id"
    t.float "score"
    t.string "status"
    t.text "synopsis"
    t.string "title"
    t.string "title_english"
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["mal_id"], name: "index_animes_on_mal_id", unique: true
  end

  create_table "genres", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "mal_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["mal_id"], name: "index_genres_on_mal_id", unique: true
  end

  create_table "studios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "mal_id"
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["mal_id"], name: "index_studios_on_mal_id", unique: true
  end

  add_foreign_key "anime_genres", "animes"
  add_foreign_key "anime_genres", "genres"
  add_foreign_key "anime_studios", "animes"
  add_foreign_key "anime_studios", "studios"
end
