class ApiService

  def deploy_initial
    begin
      request = Hash.new
      request['user_id'] = user_id
      request['following_id'] = following_id
      conn = connection
      response = conn.post do |req|
        req.url 'push_services/push_to_following'
        req.headers['Content-Type'] = 'application/json'
        req.body = request.to_json
      end
      return response.body
    rescue Exception => e
      puts e.message
    end
  end

  private
  def connection
    conn = Faraday.new(:url => "#{ENV['ZEEMI_JOB_URL']}") do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
    return conn
  end
end