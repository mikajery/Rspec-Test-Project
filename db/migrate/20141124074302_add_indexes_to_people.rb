class AddIndexesToPeople < ActiveRecord::Migration
  def change
    add_index :people, :name
    add_index :people, :email_address
  end
end
