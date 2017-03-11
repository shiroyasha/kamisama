require "kamisama/version"
require "kamisama/process_ctrl"
require "kamisama/task"

class Kamisama
  def self.run(options = {}, &block)
    new(options, &block).run
  end

  def initialize(options, &block)
    @block            = block
    @instances        = options.fetch(:instances)
    @respawn_limit    = options.fetch(:respawn_limit, 3)
    @respawn_interval = options.fetch(:respawn_interval, 60)
    @monitor_sleep    = 2
  end

  def run
    puts "[Kamisama Master] Process id: #{Process.pid}"
    puts "[Kamisama Master] Starting #{@instances} workers. \n"

    @tasks = Array.new(@instances) { |index| Kamisama::Task.new(index, @block) }
    @tasks.each(&:start)

    monitor
  end

  def monitor
    loop do
      dead_tasks = @tasks.reject(&:alive?)

      dead_tasks.each do |task|
        puts "[Kamisama Master] Restarting Worker."
        task.restart!
      end

      sleep(@monitor_sleep)
    end
  end

end
