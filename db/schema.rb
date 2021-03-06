# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_04_28_093452) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "districts", force: :cascade do |t|
    t.integer "number", null: false
    t.geography "geometry", limit: {:srid=>4326, :type=>"multi_polygon", :geographic=>true}, null: false
    t.string "name"
    t.string "name2"
    t.index ["name"], name: "index_districts_on_name"
    t.index ["number"], name: "index_districts_on_number"
  end

  create_table "ethnicities", force: :cascade do |t|
    t.string "name", null: false
  end

  create_table "statistics", force: :cascade do |t|
    t.string "type"
    t.string "year"
    t.integer "ethnicity_id"
    t.bigint "district_id"
    t.float "relative_percentage"
    t.float "total_population"
    t.index ["district_id"], name: "index_statistics_on_district_id"
    t.index ["ethnicity_id"], name: "index_statistics_on_ethnicity_id"
    t.index ["type"], name: "index_statistics_on_type"
    t.index ["year", "type", "ethnicity_id"], name: "index_statistics_on_year_and_type_and_ethnicity_id"
    t.index ["year"], name: "index_statistics_on_year"
  end

end
