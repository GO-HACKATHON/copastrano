class DockerService
	def initialize(project, tag = '', cert = nil, path = './repo')
		if tag.empty?
			tag = project
		end

		@project = project
		@tag = tag
		@path = path
		@cert = cert
	end

	def build_and_push_image
		image = Docker::Image.build_from_dir("#{@path}/#{@project}", {:t => @tag}) do |v|
		   $stdout.puts v
		end

		image.push(@cert) do |v|
			 $stdout.puts v
		end
	end
end