class Api::V1::DeploysController < Api::V1::ApiController

  def index
    @deployments = Deployment.all
    render json: {status: 200, message: 'List Data', data: @deployments.map{|r| {id: r.id, name: r.name, status: r.status, created_at: r.created_at }}}
  end

  def detail
    @deployment = Deployment.find_by(id: params[:id])
    data ={ id: @deployment.id,
            name: @deployment.name,
            status: @deployment.status,
            created_at: @deployment.created_at,
            container: @deployment.containers.map{|c|
              {
                id: c.id,
                name: c.name,
                image: c.image,
                created_at: c.created_at
              }
            },
            yml: @deployment.yml_files.map{|y|
              {
                id: y.id,
                yml_path: y.yml_path,
                created_at: y.created_at
              }
            }
    }

    render json: {status: 200, message: 'List Of Tasks', data: data}
  end


  def initial
    puts params
    begin
      file = File.read(params[:yml].tempfile)
      content = YAML::load(file)

      @deployment = Deployment.new
      @deployment.name = content['metadata']['name']
      @deployment.status = 'New'

      cont_arr = Array.new
      content['spec']['template']['spec']['containers'].each do |r|
        cont = {'name' => r['name'], 'image' => r['image']}
        cont_arr << cont
      end

      @deployment.containers.build cont_arr

      if @deployment.save

        #Upload YMl File
        file_name = "development-#{Time.now.to_i}.yml"
        directory = "#{ENV['YML_DIR']}/#{@deployment.id}/#{@yml.id}"
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
        path = File.join(directory, file_name)
        File.open(path, "wb") { |f| f.write(params[:yml].read) }

        #insert yml path
        @yml = YmlFile.new
        @yml.development_id = @deployment.id
        @yml.yml_path = path
        @yml.save

        render json: {status: 200, message: 'Initial Deploy Successful'}
      else
        render json: {status: 500, message: @metadata.errors.full_messages.to_s}
      end
    rescue => e
      render json: {status: 500, message: e.to_s}
    end


  end

  def deploy
    #call service
    #insert db
    render json: {status: 200, message: 'Deploy Successful'}
  end

  def history

  end
end