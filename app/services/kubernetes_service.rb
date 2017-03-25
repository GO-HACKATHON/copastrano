class KubernetesService
	def initialize(uri, cert = {}, namespaces = 'default')
		@uri = URI(uri)
		@namespaces = namespaces
		# basic_auth = 'admin:GZoD1VFTdFQ8ryam8uwXuWzX02zqS5d3'
		@basic_auth = "#{cert[:username]}:#{cert[:password]}"
	end

	def get_deployments
		r = RestClient::Request.execute(:url => "#{@uri.scheme}://#{@basic_auth}@#{@uri.host}/apis/extensions/v1beta1/deployments", :method => :get, :verify_ssl => false)

		r_json = JSON.parse(r)
	end

	def create_deployment(yml)
		r = RestClient::Request.execute(:url => "#{@uri.scheme}://#{@basic_auth}@#{@uri.host}/apis/extensions/v1beta1/namespaces/#{@namespaces}/deployments", :method => :post, :verify_ssl => false, :payload => yml, :headers => {:content_type=>"application/yaml"})

		r_json = JSON.parse(r)
	end

	def replace_deployment(yml, name)
		r = RestClient::Request.execute(:url => "#{@uri.scheme}://#{@basic_auth}@#{@uri.host}/apis/extensions/v1beta1/namespaces/#{@namespaces}/deployments/#{name}", :method => :put, :verify_ssl => false, :payload => yml, :headers => {:content_type=>"application/yaml"})

		r_json = JSON.parse(r)
	end
end