require 'csv'

class StatisticsCsvImporter::Runner
  attr_accessor :failures

  def initialize(file_path)
    @file_path = file_path
    @failures = []
  end

  def do_it
    start_time = Time.now

    CSV.foreach(@file_path, headers: true) do |row|
      puts "reading row #{row}"
      begin
        district = District.where(number: row["DISTRICT"]).first
        year = row["Year"]

        Statistic::VALID_TYPES.each do |stat_type, class_name|
          Ethnicity.find_each do |eth|
            begin
              next unless row["#{eth.name}-#{stat_type}-S"].present? && row["#{eth.name}-POP"].present?
              attributes = { district: district, type: class_name, ethnicity: eth, year: year }
              unless Statistic.exists?(attributes)
                Statistic.create!(attributes.merge(
                  relative_percentage: row["#{eth.name}-#{stat_type}-S"],
                  total_population: row["#{eth.name}-POP"]
                ))
              end
            rescue Exception => e
              puts "RESCUING 1: #{e.inspect}"
              @failures << "#{e.message}, ETH_NAME: #{eth.name}, STAT_TYPE: #{stat_type}, DISTRICT: #{district}, YEAR: #{year}"
              next
            end
          end
        end
      rescue SystemExit, Interrupt, IRB::Abort => e
        break
      end
    end

    elapsed = (Time.now - start_time) / 60
    puts "FINISHED IN #{elapsed.round(2)} MINUTES"
  end

  def print_errors
    puts "#{@failures.length} FAILURES:"
    @failures.each do |nf|
      puts nf.inspect
    end

    nil
  end
end
