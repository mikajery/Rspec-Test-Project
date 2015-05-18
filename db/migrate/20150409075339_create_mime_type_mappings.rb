class CreateMimeTypeMappings < ActiveRecord::Migration
  def change
    create_table :mime_type_mappings do |t|
      t.string :mime_type
      t.integer :usable_category_cd, default: 0

      t.timestamps
    end
  end
end
