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
    puts params[:yml]
    deploy = DeployService.new().initial(params)
    render json: deploy
  end

  def deploy
    #call service
    #insert db
    # DeploymentJob.perform_later(params[:deployment_id], params[:container_id])

    # Do something later
    deployment_id = params[:deployment_id]
    container_id = params[:container_id]

    deployment = Deployment.find(deployment_id)
    container = deployment.containers.find(container_id)
    path = "./repo/#{deployment.id}"
    # 1. Pull latest code
    git = GitService.new(deployment.repo_uri, 'master', path)
    git.pull

    deployment.status = 'pull'
    deployment.save

    # 2. Generate new image tag
    unix_time = Time.now.to_i
    tag_split = container.image.split(":")
    tag_split[1] = "#{unix_time}"
    new_tag = tag_split.join(":")

    deployment.status = 'gen-tag'
    deployment.save

    # 3. Build image and push
    docker = DockerService.new(deployment.repo_name, new_tag, {:username => 'adityapra', :password => 'Hijup123', :email => 'aditya@hijup.com'}, path)
    docker.build_and_push_image

    deployment.status = 'docker-build'
    deployment.save

    # 4. Generate new yaml
    yaml = YamlService.new.generate(deployment_id, container_id, container.image ,new_tag)

    deployment.status = 'gen-yaml'
    deployment.save

    # 5. Deploy
    k8s = KubernetesService.new("https://api.dev.hijup.com", {:username => 'admin', :password => 'GZoD1VFTdFQ8ryam8uwXuWzX02zqS5d3'}, 'default')
    if container.histories.count > 0
      k8s.replace_deployment(yaml.to_yaml, deployment.name)
    else
      k8s.create_deployment(yaml.to_yaml)
    end

    deployment.status = 'deployed'
    deployment.save

    history = History.create(:image_tag => new_tag, :status => 'done', :container_id => container.id)
    Rails.logger.info(history)

    render json: {status: 200, message: 'Deploy on progress'}
  end

  def history

  end
end