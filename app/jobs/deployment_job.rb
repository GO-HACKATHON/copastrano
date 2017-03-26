class DeploymentJob < ApplicationJob
  queue_as :default

  def perform(deployment_id, container_id)
    # Do something later
    deployment = Deployment.find(deployment_id)
    container = deployment.containers.find(container_id)
    path = "./repo/#{deployment.id}"
    # 1. Pull latest code
    git = GitService.new('', 'master', path)
    git.pull

    deployment.status = 'pull'
    deployment.save

    # 2. Generate new image tag
    unix_time = Time.now.to_i
    tag_split = container.image.split(":")
    tag_split[1] = unix_time
    new_tag = tag_split.join(":")

    deployment.status = 'gen-tag'
    deployment.save

    # 3. Build image and push
    docker = DockerService.new(deployment.repo_name, new_tag, nil, path)
    docker.build_and_push_image

    deployment.status = 'docker-build'
    deployment.save

    # 4. Generate new yaml
    yaml = YamlService.new.generate(deployment_id, container_id, new_tag)

    deployment.status = 'gen-yaml'
    deployment.save

    # 5. Deploy
    k8s = Kubernetes.new("https://api.dev.hijup.com", {:username => 'admin', :password => 'GZoD1VFTdFQ8ryam8uwXuWzX02zqS5d3'}, 'default')
    if deployment.containers.count > 1 
    	k8s.replace_deployment(yaml.to_yaml, deployment.name)
    else
    	k8s.create_deployment(yaml.to_yaml)
    end

    deployment.status = 'deployed'
    deployment.save
  end
end
