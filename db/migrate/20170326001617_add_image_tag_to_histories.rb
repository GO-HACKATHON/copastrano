class AddImageTagToHistories < ActiveRecord::Migration[5.0]
  def change
    add_column :histories, :image_tag, :string
  end
end
