Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :api, module: 'api', path: '/api' do

    resources :deploys, only: :index do
      collection do
        post 'initial', to: 'deploys#initial'
        get 'detail/:id', to: 'deploys#detail'
      end
    end

    resources :containers do
      collection do
        get 'list/:id', to: 'containers#list'
      end
    end
  end
end
