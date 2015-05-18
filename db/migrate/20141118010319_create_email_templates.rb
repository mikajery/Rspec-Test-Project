class CreateEmailTemplates < ActiveRecord::Migration
  def change
    create_table :email_templates do |t|
      t.belongs_to :user
      
      t.text :uid

      t.text :name
      t.text :text
      t.text :html

      t.timestamps
    end

    add_index :email_templates, [:user_id, :name], :unique => true
    add_index :email_templates, :uid, :unique => true
  end
end
