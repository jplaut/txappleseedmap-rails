require 'csv'

class StatisticsCsvImporter
  def self.do_it(file_path)
    not_found = []
    CSV.read(file_path, headers: true).each do |row|
      begin
        district = District.where(number: row["DISTRICT"]).first
        year = row["Year"]

        Statistic::VALID_TYPES.each do |stat_type, class_name|
          Ethnicity.find_each do |eth|
            attributes = { district: district, type: class_name, ethnicity: eth, year: year }
            unless Statistic.exists?(attributes)
              Statistic.create!(attributes.merge(
                relative_percentage: row["#{eth.name.downcase}_#{stat_type.downcase}_s"],
                total_population: row["#{eth.name.downcase}_pop"]
              ))
            end
          end
        end
      rescue Exception => e
        not_found << row["DISTRICT"]
      end
    end

    puts "NOT FOUND: #{not_found.join(', ')}"
  end
end
