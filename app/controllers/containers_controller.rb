class ContainersController < ApplicationController
  def index
  	@deployment = get_deployment
  	@containers = @deployment.containers.order("id desc")
  end

  def edit
  	deployment_id = params[:deployment_id]
  	container_id = params[:container_id]

  	k8s = KubernetesService.new(ENV['K8S_URI'], {:username => ENV['K8S_USER'], :password => ENV['K8S_PASSWORD']}, 'default')

  	k8s.deploying_process(deployment_id, container_id)

  	redirect_to deployment_container_histories_path(deployment_id, container_id)
  end

  private

  def get_deployment
  	deployment = Deployment.find(params[:deployment_id])
  end
end
