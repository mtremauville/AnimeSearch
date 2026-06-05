class CreateStudios < ActiveRecord::Migration[8.1]
  def change
    create_table :studios do |t|
      t.string :name
      t.integer :mal_id

      t.timestamps
    end
    add_index :studios, :mal_id, unique: true
  end
end
