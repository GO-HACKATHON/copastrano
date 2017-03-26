class AddRepoNameToDeployments < ActiveRecord::Migration[5.0]
  def change
    add_column :deployments, :repo_name, :string
  end
end
