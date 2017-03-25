class CreateYmlFiles < ActiveRecord::Migration[5.0]
  def up
    create_table :yml_files do |t|
      t.integer :deployment_id
      t.string :yml_path
      t.timestamps
    end
  end

  def down
    drop_table :yml_files
  end
end
