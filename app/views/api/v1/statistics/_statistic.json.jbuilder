json.extract! statistic, :relative_percentage, :total_population
json.district do
  json.extract! statistic.district, :number
end
json.ethnicity do
  json.extract! statistic.ethnicity, :name
end
