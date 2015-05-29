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
      t.string :address
      t.string :zip_code
      t.string :home_phone, :limit => 12
      t.string :mobile_phone, :limit => 12
      t.string :email
      t.string :citizen_id
      t.boolean :receive_updates
      t.integer :amount
      t.integer :intended_amount
      t.string :key
      t.string :cc_expiry
      t.string :cc_last4d
      t.string :cc_voucher
      t.string :cc_holder
      t.text :notes
      t.string :member_name
      t.string :member_phone
      t.timestamps
    end
  end

  def self.down
    drop_table :supporters
  end
end
