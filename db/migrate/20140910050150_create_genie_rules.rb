class CreateGenieRules < ActiveRecord::Migration
  def change
    create_table :genie_rules do |t|
      t.belongs_to :user

      t.text :uid
      
      t.text :from_address
      t.text :to_address
      t.text :subject
      t.text :list_id
      
      t.timestamps
    end

    add_index :genie_rules, :uid, :unique => true

    add_index :genie_rules, [:from_address, :to_address, :subject, :list_id],
              :unique => true, :name => 'index_genie_rules_on_everything'
  end
end
