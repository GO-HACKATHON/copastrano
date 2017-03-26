class HistoriesController < ApplicationController
  def index
  	get_container
  	@histories = @container.histories.order("id desc")
  end

  private 
  def get_container
  	@container = Container.find(params[:container_id])
  end
end
