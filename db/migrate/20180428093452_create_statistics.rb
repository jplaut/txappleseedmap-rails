class CreateStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics do |t|
      t.string :type
      t.string :year # no need for a bigint or datetime here at this point
      t.integer :ethnicity_id
      t.references :district
      t.integer :relative_percentage
      t.integer :total_population
    end

    add_index :statistics, :ethnicity_id
    add_index :statistics, :year
    add_index :statistics, :type
    add_index :statistics, [:year, :type, :ethnicity_id]
  end
end
