class Kamisama
  class Task

    def self.start(task_index, block)
      task = new(task_index, block)
      task.start
      task
    end

    def initialize(task_index, block)
      @task_index = task_index
      @block = block
    end

    def start
      @pid = Process.fork do
        begin
          # receive sigterm when parent dies
          Kamisama::ProcessCtrl.set_parent_death_signal(:sigterm)

          log("Worker started. Hello!")

          @block.call(@task_index)
        rescue Exception => e
          # handle all exceptions, even system ones
          log("Shutting down... #{e.message}")
          exit
        ensure
          exit
        end
      end

      Process.detach(@pid)
    end

    def restart!
      puts "[Kamisama Master] Restarting Worker."
      @pid = nil
      start
    end

    def terminate!
      Process.kill("TERM", @pid)
    end

    def alive?
      Process.getpgid(@pid)
      true
    rescue Errno::ESRCH
      false
    end

    def log(message)
      puts "[WORKER #{@task_index}] #{message}"
    end
  end
end
