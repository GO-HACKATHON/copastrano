class GitService
	def initialize(uri, path = './repo')
		@uri = uri
		@path = path
	end

	def clone
		repo_name = @uri.split('/')[4].split('.')[0]
		Git.clone(@uri, repo_name , :path => @path)
	end

end