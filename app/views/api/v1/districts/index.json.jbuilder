json.array!(@districts) do |district|
  json.partial! 'district', district: district
end
