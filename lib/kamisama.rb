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

    @term_signal_received = false

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
      @instances += 1
    end

    trap("TTOU") do
      # make sure that we always have at least one running worker
      if @instances > 1
        @instances -= 1
      end
    end

    trap("TERM") do
      @term_signal_received = true
    end
  end

  def add_worker
    puts "[Kamisama Master] #{Process.pid} Spawning new instance."

    @worker_index ||= 0
    @worker_index += 1

    task = Kamisama::Task.new(@worker_index, @block)
    task.start

    @tasks << task
  end

  def term_worker
    puts "[Kamisama Master] #{Process.pid} Terminating an instance."

    task = @tasks.shift
    task.terminate!
  end

  def monitor
    loop do
      break if @term_signal_received

      add_worker  while @tasks.count < @instances
      term_worker while @tasks.count > @instances

      dead_tasks = @tasks.reject(&:alive?)

      dead_tasks.each do |task|
        @respawn_limiter.record!
        task.restart!
      end

      sleep(@monitor_sleep)
    end

    puts "[Kamisama Master] #{Process.pid} Terminating all instances"
    @tasks.each(&:terminate!)
    exit
  end

end
