class Kamisama
  require "kamisama/version"
  require "kamisama/process_ctrl"
  require "kamisama/task"
  require "kamisama/task_group"
  require "kamisama/respawn_limiter"

  MONITOR_SLEEP = 2

  def self.run(options = {}, &block)
    puts "[Kamisama Master] Process id: #{Process.pid}"

    new(options, &block).run
  end

  def initialize(options, &block)
    @task_group = Kamisama::TaskGroup.new(
      options.fetch(:instances),
      options[:respawn_limit] || 10,
      options[:respawn_interval] || 10,
      &block)
  end

  def run
    trap("TERM") do
      @task_group.terminate_all_tasks
      exit
    end

    loop do
      @task_group.check_tasks
      sleep(MONITOR_SLEEP)
    end
  end

end
