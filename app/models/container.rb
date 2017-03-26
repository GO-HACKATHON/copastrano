class Container < ActiveRecord::Base
  belongs_to :deployment
  has_many :histories
end