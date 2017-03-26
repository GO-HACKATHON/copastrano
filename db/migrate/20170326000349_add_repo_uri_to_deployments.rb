class AddRepoUriToDeployments < ActiveRecord::Migration[5.0]
  def change
    add_column :deployments, :repo_uri, :string
  end
end
