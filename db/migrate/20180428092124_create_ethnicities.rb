class CreateEthnicities < ActiveRecord::Migration[5.2]
  def change
    create_table :ethnicities do |t|
      t.string :name, null: false
    end
  end
end
