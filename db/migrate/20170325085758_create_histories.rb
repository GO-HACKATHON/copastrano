class CreateHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :histories do |t|
      t.integer :container_id
      t.string :status
      t.timestamps
    end
  end
end
