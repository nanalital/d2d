class CreateAccounts < ActiveRecord::Migration
  def self.up
    create_table :accounts do |t|
      t.string :name
      t.string :surname
      t.string :email
      t.string :crypted_password
      t.string :role
      t.string :city_id
      t.string :location_id
      t.integer :old_id
      t.timestamps
    end
  end

  def self.down
    drop_table :accounts
  end
end
