class CreateIpInfos < ActiveRecord::Migration
  def change
    create_table :ip_infos do |t|
      t.inet :ip
      t.text :country_code
      t.text :country_name
      t.text :region_code
      t.text :region_name
      t.text :city
      t.text :zipcode
      t.text :latitude
      t.text :longitude
      t.text :metro_code
      t.text :area_code
      
      t.timestamps
    end

    add_index :ip_infos, :ip, :unique => true
  end
end
