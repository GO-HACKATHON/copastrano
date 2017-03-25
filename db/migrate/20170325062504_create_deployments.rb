class CreateDeployments < ActiveRecord::Migration[5.0]
  def up
    create_table :deployments do |t|
      t.string :name
      t.string :status
      t.timestamps
    end
  end

  def down
    drop_table :deployments
  end
end
