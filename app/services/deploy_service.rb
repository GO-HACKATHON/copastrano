class DeployService
  def initial (params)
    begin
      file = File.read(params['yml'].tempfile)
      content = YAML::load(file)

      @deployment = Deployment.new
      @deployment.name = content['metadata']['name']
      @deployment.status = 'New'
      @deployment.repo_name = params['git_repo_url'].split('/')[4].split('.')[0]

      cont_arr = Array.new
      content['spec']['template']['spec']['containers'].each do |r|
        cont = {'name' => r['name'], 'image' => r['image']}
        cont_arr << cont
      end

      @deployment.containers.build cont_arr

      if @deployment.save
        #Upload YMl File
        file_name = "development-#{Time.now.to_i}.yml"
        directory = "#{ENV['YML_DIR']}/#{@deployment.id}"
        FileUtils.mkdir_p(directory) unless File.directory?(directory)
        path = File.join(directory, file_name)
        File.open(path, "wb") { |f| f.write(params[:yml].read) }

        #insert yml path
        @yml = YmlFile.new
        @yml.deployment_id = @deployment.id
        @yml.yml_path = path
        @yml.save

        GitCloneJob.perform_later(params['git_repo_url'], @deployment.id)
        return {status: 200, message: 'Initial Deploy Successful'}
      else
        return {status: 500, message: @metadata.errors.full_messages.to_s}
      end
    rescue => e
      return {status: 500, message: "YML file is not valid : #{e}"}
    end
  end

  def deploy (params)
    #call service
    #insert db
    # DeploymentJob.perform_later(params[:deployment_id], params[:container_id])

    # Do something later
    deployment_id = params['deployment_id']
    container_id = params['container_id']

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
    docker = DockerService.new(deployment.repo_name, new_tag, {:username => ENV['DOCKER_USER'], :password => ENV['DOCKER_PASSWORD'], :email => ENV['DOCKER_EMAIL']}, path)
    docker.build_and_push_image

    deployment.status = 'docker-build'
    deployment.save

    # 4. Generate new yaml
    yaml = YamlService.new.generate(deployment_id, container_id, container.image ,new_tag)

    deployment.status = 'gen-yaml'
    deployment.save

    # 5. Deploy
    k8s = KubernetesService.new(ENV['K8S_URI'], {:username => ENV['K8S_USER'], :password => ENV['K8S_PASSWORD']}, 'default')
    if container.histories.count > 0
      k = k8s.replace_deployment(yaml.to_yaml, deployment.name)
    else
      is_conflict = k8s.create_deployment(yaml.to_yaml)
      if !is_conflict
        k8s.replace_deployment(yaml.to_yaml, deployment.name)
      end
    end

    deployment.status = 'deployed'
    deployment.save

    history = History.create(:image_tag => new_tag, :status => 'done', :container_id => container.id)
    Rails.logger.info(history)

    render json: {status: 200, message: 'Deploy on progress'}
  end
end