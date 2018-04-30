namespace :db do
  desc "Import district GeoJSON"
  task import_districts: :environment do
    DistrictGeojsonImporter.do_it(Rails.root.join('data', 'iss_districts.geojson'))
  end

  desc "Import yearly school district data"
  task import_statistics: :environment do |_t, args|
    path = Rails.root.join('data', 'schoolToPrison_flat.csv')
    importer = StatisticsCsvImporter::Runner.new(path)
    importer.do_it
  end
end
