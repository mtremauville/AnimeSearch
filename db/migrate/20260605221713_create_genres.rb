class CreateGenres < ActiveRecord::Migration[8.1]
  def change
    create_table :genres do |t|
      t.string :name
      t.integer :mal_id

      t.timestamps
    end
    add_index :genres, :mal_id, unique: true
  end
end
