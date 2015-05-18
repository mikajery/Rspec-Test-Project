class CreateSkins < ActiveRecord::Migration
  def change
    create_table :skins do |t|
      t.text :uid
      t.text :name

      t.timestamps
    end
  end
end
