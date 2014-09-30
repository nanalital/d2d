class AddSupporterResultColumn < ActiveRecord::Migration
  def self.up
    add_column :supporters, :result, :string
  end

  def self.down
    remove_column :supporters, :result
  end
end
