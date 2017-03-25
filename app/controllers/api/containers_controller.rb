class Api::ContainersController < Api::ApiController

  def list
    @containers = Container.where(deployment_id: params[:id])
    render json: {status: 200, message: 'List Data', data: @containers.map{|r| {id: r.id, name: r.name, image: r.image}}}
  end
end