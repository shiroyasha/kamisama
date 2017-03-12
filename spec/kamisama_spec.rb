require "spec_helper"

describe Kamisama do
  it "has a version number" do
    expect(Kamisama::VERSION).not_to be nil
  end

  describe "starting workers" do
    before do
      @pid = TestApp.start(:instances => 3)
    end

    it "starts multiple workers" do
      expect(SpecHelpers.child_count(@pid)).to eq(3)
    end

    after do
      TestApp.stop(@pid, :signal => "KILL")
      expect(SpecHelpers.child_count(@pid)).to eq(0)
    end
  end

  describe "restarting failed workers" do
    before do
      @pid = TestApp.start(:instances => 3)
      expect(SpecHelpers.child_count(@pid)).to eq(3)
    end

    it "restart failed worker" do
      children = SpecHelpers.child_pids(@pid)

      puts "Killing #{children.first}"
      Process.kill("TERM", children.first)

      # make sure that we actually killed a child
      sleep 1
      expect(SpecHelpers.child_count(@pid)).to eq(2)

      # wait for worker to respawn
      sleep 4
      expect(SpecHelpers.child_count(@pid)).to eq(3)
    end

    after do
      TestApp.stop(@pid, :signal => "KILL")
      expect(SpecHelpers.child_count(@pid)).to eq(0)
    end
  end

  describe "respawning" do
    before do
      @pid = TestApp.start(:instances => 3, :respawn_limit => 2, :respawn_interval => 10)
      expect(SpecHelpers.child_count(@pid)).to eq(3)
      sleep 3
    end

    it "obbeys the respawn count and respawn interval parameters" do
      Process.kill("TERM", SpecHelpers.child_pids(@pid).first)
      sleep 3
      Process.kill("TERM", SpecHelpers.child_pids(@pid).first)
      sleep 3

      expect(SpecHelpers.process_alive?(@pid)).to eq(false)
    end

    after do
      TestApp.stop(@pid, :signal => "KILL") if SpecHelpers.process_alive?(@pid)
      expect(SpecHelpers.child_count(@pid)).to eq(0)
    end
  end

end
