class GitCloneJob < ApplicationJob
  queue_as :default

  def perform(git_repo_url, deployment_id)
    # Do something later
    path = "./repo/#{deployment_id}"
    FileUtils.mkdir_p(path) unless File.directory?(path)
    git = GitService.new(git_repo_url, "master", path)
    git.clone
  end
end