require "spec_helper"

describe Kamisama do
  it 'has a version number' do
    expect(Kamisama::VERSION).not_to be nil
  end

  describe ".run" do
    it "starts multiple instances" do

      pid = Process.fork do
        Kamisama.run(:instances => 3) do |index|

          while true
            puts "a #{index}"
            sleep 2
          end

        end
      end

      puts "Observing process"
      sleep 3

      puts "Killing process"
      Process.kill("KILL", pid)

      sleep 1

      system("ps aux | grep 'ruby' | grep 'kamisama'")
      system('ps aux | grep "kamisama" | grep "ruby" | awk \'{ print $2 }\' | xargs kill')
    end
  end
end
