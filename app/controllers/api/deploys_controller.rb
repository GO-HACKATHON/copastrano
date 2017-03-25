class Api::DeploysController < Api::ApiController

  def index
    @deployments = Deployment.all
    render json: {status: 200, message: 'List Data', data: @deployments.map{|r| {id: r.id, name: r.name }}}
  end

  def detail
    @deployment = Deployment.find_by(id: params[:id])
    data ={ id: @deployment.id,
            name: @deployment.name,
            container: @deployment.containers.map{|c|
              {
                id: c.id,
                name: c.name,
                image: c.image
              }
            },
            yml: @deployment.yml_files.map{|y|
              {
                id: y.id,
                yml_path: y.yml_path
              }
            }
    }

    render json: {status: 200, message: 'List Of Tasks', data: data}
  end


  def initial
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
    @yml = @deployment.yml_files.build ({'yml_path' => ''})

    if @deployment.save

      #Upload YMl File
      file_name = params[:yml].original_filename
      directory = "#{ENV['YML_DIR']}/#{@deployment.id}/#{@yml.id}"
      FileUtils.mkdir_p(directory) unless File.directory?(directory)
      path = File.join(directory, file_name)
      File.open(path, "wb") { |f| f.write(params[:yml].read) }

      #update yml path
      @yml.yml_path = path
      @yml.save

      render json: {status: 200, message: 'Initial Deploy Successful'}
    else
      render json: {status: 500, message: @metadata.errors.full_messages.to_s}
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