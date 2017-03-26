ActiveAdmin.register Deployment, as: 'Deploys'  do
  menu priority: 2
  actions :all, :except => [:new, :edit, :destroy]

  index do
    column :id
    column :name
    column :status
    column :created_at
    column 'Action' do |m|
      link_to('Deploy', "#{deploy_admin_deploys_path}?id=#{m.id}")
    end
  end


    form do |f|
    f.inputs 'Fill Form' do
      f.input :yml, label: 'YML File', as: :file, :multipart => true
    end
    f.actions
    end

  collection_action :deploy, :method=>:get
  collection_action :deploy_do, :method=>:post
  collection_action :new_init, :method => :get
  collection_action :save_init, :method => :post

  controller do
    def create
      data = Hash.new
      deployment = params[:deployment]
      puts deployment['yml']
      data['yml'] = params[:deployment][:yml]
      data['git_repo_url'] = 'https://github.com/GO-HACKATHON/multiverse/tree/master/aerospike'

      a  = DeployService.new().initial(data)
      redirect_to admin_deploys_path
    end

    def deploy
      @containers = Container.where(deployment_id: params[:id])
      @deployment_id = params[:id]
    end

    def deploy_do
      DeployService.new().deploy(params)
      redirect_to admin_deploys_path
    end


    def new_init

    end

    def save_init
      DeployService.new().initial(params)
      redirect_to admin_deploys_path
    end
  end

  action_item(:index) do
    link_to 'New Deployment', new_init_admin_deploys_path
  end


end
