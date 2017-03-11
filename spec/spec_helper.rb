$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'kamisama'
require "sys/proctable"

module SpecHelpers
  module_function

  def child_count(pid)
    Sys::ProcTable.ps.select { |process| process.ppid == pid }.count
  end
end

class TestApp

  def self.start(options)
    pid = Process.fork do
      Kamisama.run(:instances => options.fetch(:workers)) do |index|
        worker(index)
      end
    end

    # wait for children to spawn
    sleep 2
    pid
  end

  def self.worker(index)
    while true
      puts "worker #{index} ... crunching data ..."
      sleep 2
    end
  end

  def self.stop(pid, options = {})
    signal = options.fetch(:signal)

    puts "Stopping TestAPP with #{signal}"
    Process.kill(signal, pid)

    sleep 1
  end

end
