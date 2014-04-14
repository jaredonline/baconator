class CreateMovies < ActiveRecord::Migration
  def change
    create_table :movies do |t|
      t.integer :bacon_link_id

      t.string :name
      t.string :image_url
      t.string :filename

      t.timestamps
    end
  end
end
