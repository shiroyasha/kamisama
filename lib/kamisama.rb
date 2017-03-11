require "kamisama/version"
require "kamisama/process_ctrl"
require "kamisama/task"

module Kamisama
  module_function

  def run(options = {}, &block)
    instances = options.fetch(:instances)

    tasks = Array.new(instances) { |index| Kamisama::Task.new(index, &block) }

    tasks.each(&:start)

    Process.waitall
  end

end
