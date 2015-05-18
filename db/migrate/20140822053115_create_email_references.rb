class CreateEmailReferences < ActiveRecord::Migration
  def change
    create_table :email_references do |t|
      t.belongs_to :email

      t.text :references_message_id
      t.integer :position

      t.timestamps
    end

    add_index :email_references, :email_id
    add_index :email_references, [:email_id, :references_message_id, :position],
              :unique => true, :name => 'index_email_references_on_email_and_references_msg_id_and_pos'
  end
end
