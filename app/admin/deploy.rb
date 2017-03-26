ActiveAdmin.register Deployment, as: 'Deploys'  do
  menu priority: 2
  actions :all, :except => [:edit, :destroy]

  index do
    column :id
    column :name
    column :status
    column :created_at
  end


  form do |f|
    f.inputs 'Fill Form' do
      f.input :yml, label: 'YML File', as: :file, :multipart => true
      # f.input 'git'
    end
    f.actions
  end

  controller do
    def create
      redirect_to initial_api_deploys_path and return
    end
  end


end
