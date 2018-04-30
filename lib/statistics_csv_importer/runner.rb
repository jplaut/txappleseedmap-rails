require 'csv'

class StatisticsCsvImporter::Runner
  attr_accessor :failures

  DEFAULT_MAX_THREADS = 5
  THREAD_TIMEOUT = 15

  def initialize(file_path, max_threads = DEFAULT_MAX_THREADS)
    @failed_mutex = Mutex.new
    @file_path = file_path
    @max_threads = max_threads
    @old_logger = ActiveRecord::Base.logger
    @failures = []
    @previous_pool_size = ActiveRecord::Base.configurations[Rails.env]['pool']

    StatisticsCsvImporter::ImportJob.workers @max_threads
    ::SuckerPunch.exception_handler = -> (ex, klass, args) { handle_exception(ex, klass, args) }
    ::SuckerPunch.shutdown_timeout = THREAD_TIMEOUT
  end

  def do_it
    start_time = Time.now
    start

    CSV.foreach(@file_path, headers: true) do |row|
      begin
        i = $.
        StatisticsCsvImporter::ImportJob.perform_async(row, i)
      rescue SystemExit, Interrupt, IRB::Abort => e
        ::SuckerPunch::Queue.shutdown_all
      end
    end

    loop do
      begin
        queue = SuckerPunch::Queue.find_or_create(StatisticsCsvImporter::ImportJob.to_s)
        if queue.queue_length == 0 && queue.busy_workers == 0
          elapsed = (Time.now - start_time) / 60
          puts "FINISHED IN #{elapsed.round(2)} MINUTES"
          finish
          break
        end
      rescue SystemExit, Interrupt, IRB::Abort => e
        ::SuckerPunch::Queue.shutdown_all
        break
      end
    end
  end

  def print_errors
    @failed_mutex.synchronize do
      puts "#{@failures.length} FAILURES:"
      @failures.each do |nf|
        puts nf.inspect
      end

      nil
    end
  end

  def handle_exception(ex, klass, args)
    puts "got exception: #{ex}"
    @failed_mutex.synchronize do
      @failures << ex
    end
  end

  def finish
    @queue.kill
    ActiveRecord::Base.connection.disconnect!
    ActiveRecord::Base.configurations[Rails.env]['pool'] = @previous_pool_size
    ActiveRecord::Base.establish_connection
    ActiveRecord::Base.logger = @old_logger
  end

  def start
    ActiveRecord::Base.logger = nil
    ActiveRecord::Base.connection.disconnect!
    ActiveRecord::Base.configurations[Rails.env]['pool'] = @max_threads
    ActiveRecord::Base.establish_connection
  end
end
