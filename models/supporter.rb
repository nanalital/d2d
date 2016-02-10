#coding:utf-8
class Supporter < ActiveRecord::Base

  validates_uniqueness_of :uniqnum
  validates_presence_of :amount, :account_id, :dd_location, :message => 'שדה חובה'
  validates_numericality_of :amount, :greater_than_or_equal_to => 40, :message => "סכום המינימום הוא 40 ש״ח"
  validate :unique

  belongs_to :account

  before_validation :fix_account

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

  def fix_account
    if self.dd_location && self.dd_location.to_i != 0
      location_obj = Location.find(self.dd_location)
      self.dd_city = location_obj.city_id if location_obj
    elsif self.account && self.account_id != 0
      self.dd_city = self.account.city_id
      self.dd_location = self.account.location_id
    end

    p self.attributes
  end

end
