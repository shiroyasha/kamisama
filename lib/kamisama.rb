class Kamisama
  require "kamisama/version"
  require "kamisama/process_ctrl"
  require "kamisama/task"
  require "kamisama/respawn_limiter"

  def self.run(options = {}, &block)
    new(options, &block).run
  end

  def initialize(options, &block)
    @block            = block
    @instances        = options.fetch(:instances)
    @respawn_limit    = options.fetch(:respawn_limit, 3)
    @respawn_interval = options.fetch(:respawn_interval, 60)
    @monitor_sleep    = 2

    @respawn_limiter = Kamisama::RespawnLimiter.new(@respawn_limit, @respawn_interval)
    @tasks = []
  end

  def run
    puts "[Kamisama Master] Process id: #{Process.pid}"
    puts "[Kamisama Master] Starting #{@instances} workers. \n"

    @instances.times { add_worker }

    handle_signals

    monitor
  end

  def handle_signals
    trap("TTIN") do
      puts "[Kamisama Master] #{Process.pid} Spawning new instance."

      @instances += 1
    end
  end

  def add_worker
    task = Kamisama::Task.new(@tasks.count, @block)
    task.start

    @tasks << task
  end

  def monitor
    loop do
      add_worker while @tasks.count < @instances

      dead_tasks = @tasks.reject(&:alive?)

      dead_tasks.each do |task|
        @respawn_limiter.record!
        task.restart!
      end

      sleep(@monitor_sleep)
    end
  end

end
