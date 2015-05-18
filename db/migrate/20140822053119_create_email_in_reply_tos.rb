class CreateEmailInReplyTos < ActiveRecord::Migration
  def change
    create_table :email_in_reply_tos do |t|
      t.belongs_to :email

      t.text :in_reply_to_message_id
      t.integer :position

      t.timestamps
    end

    add_index :email_in_reply_tos, :email_id
    add_index :email_in_reply_tos, [:email_id, :in_reply_to_message_id, :position],
              :unique => true, :name => 'index_email_in_reply_to_on_email_and_in_reply_to_msg_id_and_pos'
  end
end
