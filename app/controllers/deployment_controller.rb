class DeploymentController < ApplicationController
  def index
  	@deployments = Deployment.order("id desc")
  end

  def new
  end
end
