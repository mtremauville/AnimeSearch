class CreateAnimes < ActiveRecord::Migration[8.1]
  def change
    create_table :animes do |t|
      t.string :title
      t.string :title_english
      t.text :synopsis
      t.float :score
      t.integer :year
      t.integer :mal_id
      t.string :image_url
      t.integer :episodes
      t.string :status

      t.timestamps
    end
    add_index :animes, :mal_id, unique: true
  end
end
