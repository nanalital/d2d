class Supporter < ActiveRecord::Base
  validate :unique
  belongs_to :account

  def amount
    if self.ap_monthly > 0
      return self.ap_monthly
    elsif self.ap_one_off > 0
      return self.ap_one_off
    else
      return 50
    end
  end

  def self.randomize
    'p'+(0..6).map{ ((0..9).to_a)[rand(10)] }.join
  end

  def inspect
    self.uniqnum
  end

  private
  def unique
    if self.new_record? && (self.uniqnum == nil || Supporter.find_by_uniqnum(self.uniqnum))
      self.uniqnum = Supporter.randomize
    end
  end


end
