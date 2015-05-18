class CreateEmailTemplateCategories < ActiveRecord::Migration
  def change
    # email template categories migration
    create_table :email_template_categories do |t|
      t.belongs_to :user

      t.text :uid
      t.text :name

      t.integer :email_templates_count

      t.timestamps
    end

    add_index :email_template_categories, [:user_id, :name], :unique => true
    add_index :email_template_categories, :uid, :unique => true

    # email template migration
    add_column :email_templates, :email_template_category_id, :integer
  end
end
