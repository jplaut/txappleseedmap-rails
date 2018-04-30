class DistrictGeojsonImporter
  def self.do_it(file_path)
    file = File.read(file_path)
    features = JSON.parse(file)['features']
    failed = []
    features.each do |feature|
      begin
        geometry = RGeo::GeoJSON.decode(feature['geometry'])
        geometry = geometry.geometry_type === RGeo::Feature::Polygon ? RGeo::Geographic.spherical_factory(:srid => 4326).multi_polygon([geometry]) : geometry
        unless District.exists?(number: feature['properties']['DISTRICT_N'])
          District.create!(
            geometry: geometry,
            number: feature['properties']['DISTRICT_N'],
            name: feature['properties']['DISTNAME'],
            name2: feature['properties']['NAME2']
          )
        end
      rescue Exception => e
        failed << [feature['properties']['DISTRICT_N'], feature['properties']['DISTNAME']]
      end
    end

    puts "COULD NOT IMPORT #{failed.length} DISTRICTS:"
    failed.each do |f|
      puts f.inspect
    end
  end
end
