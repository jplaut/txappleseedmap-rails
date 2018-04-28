class DistrictGeojsonImporter
  def self.do_it(file_path)
    file = File.read(file_path)
    features = JSON.parse(file)['features']
    features.each do |feature|
      begin
        geometry = RGeo::GeoJSON.decode(feature['geometry'])
        geometry = geometry.geometry_type === RGeo::Feature::Polygon ? RGeo::Geographic.spherical_factory(:srid => 4326).multi_polygon([geometry]) : geometry
        District.create!(
          geometry: geometry,
          number: feature['properties']['DISTRICT_N'],
          name: feature['properties']['DISTNAME'],
          name2: feature['properties']['NAME2']
        )
      rescue Exception => e
        nil
      end
    end
  end
end
