class Supporter < ActiveRecord::Base
  validates_uniqueness_of :uniqnum
  validate :unique
  belongs_to :account

  before_save :beforesave

  def self.randomize
    'p'+(0..5).map{ ((0..9).to_a)[rand(10)] }.join
  end

=begin
  def inspect
    self.uniqnum
  end
=end

  private

  def unique
    while self.new_record? && (self.uniqnum == nil || Supporter.find_by_uniqnum(self.uniqnum))
      self.uniqnum = Supporter.randomize
    end
  end

  def beforesave
    if self.dd_location
      location_obj = Location.find(self.dd_location)
      self.dd_city = location_obj.city_id if location_obj
    elsif self.account
      self.dd_city = self.account.city_id
      self.dd_location = self.account.location_id
    end

    p self.attributes
  end

end
