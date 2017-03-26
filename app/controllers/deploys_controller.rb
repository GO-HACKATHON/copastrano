class DeploysController < ApplicationController
  def index
    @deployments = Deployment.all
  end

  def new
  end

  def create
  end

  def show
  end
end
