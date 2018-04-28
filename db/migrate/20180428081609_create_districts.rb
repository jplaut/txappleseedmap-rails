class CreateDistricts < ActiveRecord::Migration[5.2]
  def change
    enable_extension('postgis') unless extensions.include?('postgis')

    create_table :districts do |t|
      t.integer :number, null: false
      t.multi_polygon :geometry, null: false, geographic: true
      t.string :name
      t.string :name2
    end

    add_index :districts, :number
    add_index :districts, :name
  end
end
