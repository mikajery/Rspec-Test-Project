class AddAddressIndexesToEmails < ActiveRecord::Migration
  def change
    add_index :emails, :from_address
    add_index :emails, :sender_address
    add_index :emails, :reply_to_address
  end
end
