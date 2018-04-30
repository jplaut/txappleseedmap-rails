json.array!(@statistics) do |statistic|
  json.partial! 'statistic', statistic: statistic
end
