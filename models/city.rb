class City < ActiveRecord::Base
  has_many :accounts
  has_many :locations
  accepts_nested_attributes_for :locations

end
