class Deployment < ActiveRecord::Base

  has_many :containers
  has_many :yml_files

  def newest_yml_file
		yml_files.order('yml_files.id desc').first
  end

  def newest_contaniner
  	yml_files.order('yml_files.id desc').first
  end
end