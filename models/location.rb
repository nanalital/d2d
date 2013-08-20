class Location < ActiveRecord::Base
  has_many :accounts
  belongs_to :city

end
