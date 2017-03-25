class CreateContainers < ActiveRecord::Migration[5.0]
  def up
    create_table :containers do |t|
      t.integer :deployment_id
      t.string :name
      t.string :image
      t.timestamps
    end
  end

  def down
    drop_table :containers
  end
end
