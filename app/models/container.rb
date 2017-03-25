class Container < ActiveRecord::Base
  belongs_to :deployment
  has_many :history
end