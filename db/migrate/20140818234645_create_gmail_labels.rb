class CreateGmailLabels < ActiveRecord::Migration
  def change
    create_table :gmail_labels do |t|
      t.belongs_to :gmail_account

      t.text :label_id
      t.text :name
      t.text :message_list_visibility
      t.text :label_list_visibility
      t.text :label_type

      t.timestamps
    end

    add_index :gmail_labels, [:gmail_account_id, :label_id], :unique => true
    add_index :gmail_labels, [:gmail_account_id, :name], :unique => true
    add_index :gmail_labels, :gmail_account_id
  end
end
