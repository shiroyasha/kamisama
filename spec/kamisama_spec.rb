require "spec_helper"

describe Kamisama do
  it "has a version number" do
    expect(Kamisama::VERSION).not_to be nil
  end

  around do |example|
    @pid = TestApp.start(:workers => 3)

    example.run

    TestApp.stop(@pid, :signal => "KILL")

    expect(SpecHelpers.child_count(@pid)).to eq(0)
  end

  it "starts multiple workers" do
    expect(SpecHelpers.child_count(@pid)).to eq(3)
  end

  it "restarts failed workers" do
    children = SpecHelpers.child_pids(@pid)

    puts "Killing #{children.first}"
    Process.kill("TERM", children.first)

    sleep 1
    expect(SpecHelpers.child_count(@pid)).to eq(2)

    # wait for worker to respawn
    sleep 4

    expect(SpecHelpers.child_count(@pid)).to eq(3)
  end

end
