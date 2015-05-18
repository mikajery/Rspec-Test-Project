class CreateInstalledPanelApps < ActiveRecord::Migration
  def change
    create_table :installed_panel_apps do |t|
      t.text :panel, :default => "right"
      t.integer :position, :default => 0

      t.timestamps
    end
  end
end
