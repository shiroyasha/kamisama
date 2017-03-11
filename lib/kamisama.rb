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

    Process.waitall
  end

end
