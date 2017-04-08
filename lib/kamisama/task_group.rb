class Kamisama::TaskGroup

  def initialize(instance_count, respawn_limit, respawn_interval, &block)
    @instances_count = instance_count
    @respawn_limiter  = Kamisama::RespawnLimiter.new(respawn_limit, respawn_interval)

    @block = block
    @tasks = []
  end

  def check_tasks
    spawn_missing_tasks
    terminate_excess_tasks

    respawn_dead_tasks
  end

  def increase_instance_count
    @instances_count += 1
  end

  def decrease_instance_count
    @instances_count -= 1 if @instances_count > 1
  end

  def spawn_missing_tasks
    while @tasks.count < @instances_count
      puts "[Kamisama Master] #{Process.pid} Spawning new instance."

      @tasks << Kamisama::Task.start(0, @block)
    end
  end

  def terminate_excess_tasks
    while @tasks.count > @instances_count
      puts "[Kamisama Master] #{Process.pid} Terminating an instance."

      @tasks.shift.terminate!
    end
  end

  def respawn_dead_tasks
    @tasks.reject(&:alive?).each do |task|
      @respawn_limiter.record!
      task.restart!
    end
  end

  def terminate_all_tasks
    puts "[Kamisama Master] #{Process.pid} Terminating all instances"

    @tasks.each(&:terminate!)
  end

end
