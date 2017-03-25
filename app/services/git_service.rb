class GitService
	def initialize(uri, branch = 'master', path = './repo')
		@uri = uri
		@path = path
		@branch = branch
	end

	def clone
		repo_name = @uri.split('/')[4].split('.')[0]
		Git.clone(@uri, repo_name , :path => @path)
	end

	def pull
		repo_name = @uri.split('/')[4].split('.')[0]
		g = Git.open("#{@path}/#{repo_name}", :log => Logger.new(STDOUT))
		g.pull
	end
end