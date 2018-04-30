json.type "FeatureCollection"
json.features do
  json.array!(@districts) do |district|
    json.type "Feature"
    json.geometry RGeo::GeoJSON.encode(district.geometry)
  end
end
