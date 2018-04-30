class StatisticsCsvImporter::ImportJob
  include ::SuckerPunch::Job

  def perform(row, i)
    ActiveRecord::Base.connection_pool.with_connection do
      district = District.where(number: row["DISTRICT"]).first
      year = row["Year"]

      Statistic::VALID_TYPES.each do |stat_type, class_name|
        Ethnicity.find_each do |eth|
          begin
            return unless row["#{eth.name}-#{stat_type}-S"].present? && row["#{eth.name}-POP"].present?
            attributes = { district: district, type: class_name, ethnicity: eth, year: year }
            unless Statistic.exists?(attributes)
              Statistic.create!(attributes.merge(
                relative_percentage: row["#{eth.name}-#{stat_type}-S"],
                total_population: row["#{eth.name}-POP"]
              ))
            end
          rescue Exception => e
            message = "#{e.message}, ETH_NAME: #{eth.name}, STAT_TYPE: #{stat_type}, DISTRICT: #{district}, YEAR: #{year}"
            raise Exception.new(message)
          end
        end
      end
    end
  end
end
