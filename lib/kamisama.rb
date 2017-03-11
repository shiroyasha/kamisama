require "kamisama/version"

module Kamisama
  module_function

  @@children = []

  def run(options = {}, &block)
    instances = options.fetch(:instances)

    instances.times do |index|
      puts "[Kamisama] Starting worker #{index}"

      @@children << Process.fork do
        block.call(index)
      end

    end
  end

end
