class Supporter < ActiveRecord::Base
  validates_uniqueness_of :uniqnum
  validate :unique
  belongs_to :account

  def amount
    return self.ap_monthly
  end

  def self.randomize
    'p'+(0..5).map{ ((0..9).to_a)[rand(10)] }.join
  end

  def inspect
    self.uniqnum
  end

  private
  def unique
    while self.new_record? && (self.uniqnum == nil || Supporter.find_by_uniqnum(self.uniqnum))
      self.uniqnum = Supporter.randomize
    end
  end


end
