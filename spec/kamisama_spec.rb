require "spec_helper"

describe Kamisama do
  it "has a version number" do
    expect(Kamisama::VERSION).not_to be nil
  end

  describe ".run" do
    it "starts multiple instances" do
      pid = TestApp.start(:workers => 3)

      expect(SpecHelpers.child_count(pid)).to eq(3)

      TestApp.stop(pid, :signal => "KILL")

      expect(SpecHelpers.child_count(pid)).to eq(0)
    end
  end
end
