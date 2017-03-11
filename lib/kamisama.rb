require "kamisama/version"
require "kamisama/process_ctrl"
require "kamisama/task"

module Kamisama
  module_function

  def run(options = {}, &block)
    puts "[Kamisama Master] Process id: #{Process.pid}"

    instances = options.fetch(:instances)

    puts "[Kamisama Master] Starting #{instances} workers"
    puts

    tasks = Array.new(instances) { |index| Kamisama::Task.new(index, &block) }

    tasks.each(&:start)

    monitor(tasks)
  end

  def monitor(tasks)
    loop do
      tasks.each do |task|
        puts "test"
        unless task.alive?

          puts "REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
        end
      end

      sleep 2
    end
  end

end
