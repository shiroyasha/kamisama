module Kamisama
  class Task
    def initialize(task_index, &block)
      @task_index = task_index
      @block = block
    end

    def start
      @pid = Process.fork do
        begin
          log("Worker started. Hello!")
          Kamisama::ProcessCtrl.set_parent_death_signal(Kamisama::ProcessCtrl::LibC::SIGTERM)

          @block.call(@task_index)
        rescue Exception => e
          # handle all exceptions, even system ones
          log("Shutting down... #{e.message}")
        end
      end
    end

    def log(message)
      puts "[WORKER #{@task_index}] #{message}"
    end
  end
end
