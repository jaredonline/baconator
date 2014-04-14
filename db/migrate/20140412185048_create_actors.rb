class CreateActors < ActiveRecord::Migration
  def change
    create_table :actors do |t|
      t.integer :bacon_link_id

      t.string :name
      t.string :image_url

      t.timestamps
    end
  end
end
