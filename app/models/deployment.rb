class Deployment < ActiveRecord::Base

  has_many :containers
  has_many :yml_files
end