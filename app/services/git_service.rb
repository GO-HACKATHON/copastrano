class GitService
	def initialize(uri, branch = 'master', path = './repo')
		@uri = uri
		@path = path
		@branch = branch
		@name = repo_name = @uri.split('/')[4].split('.')[0]
	end

	def clone
		Git.clone(@uri, @name , :path => @path)
	end

	def pull
		g = Git.open("#{@path}/#{@name}", :log => Logger.new(STDOUT))
		g.pull
	end
end