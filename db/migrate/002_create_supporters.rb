class CreateSupporters < ActiveRecord::Migration
  def self.up
    create_table :supporters do |t|
      t.string :uniqnum
      t.date :acquired
      t.integer :account_id
      t.string :dd_city
      t.string :dd_location
      t.string :first_name
      t.string :last_name
      t.integer :gender
      t.date :birthday
      t.string :occupation
      t.string :city
      t.string :street_name
      t.string :num_building
      t.string :num_apartment
      t.string :zip_code
      t.string :home_phone, :limit => 12
      t.string :mobile_phone, :limit => 12
      t.string :email
      t.boolean :receive_updates
      t.boolean :existing
      t.integer :ap_monthly, :limit => 9999
      t.integer :ap_one_off, :limit => 9999
      t.text :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :supporters
  end
end
