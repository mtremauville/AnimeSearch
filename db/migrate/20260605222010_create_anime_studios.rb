class CreateAnimeStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :anime_studios do |t|
      t.references :anime, null: false, foreign_key: true
      t.references :studio, null: false, foreign_key: true

      t.timestamps
    end
  end
end
