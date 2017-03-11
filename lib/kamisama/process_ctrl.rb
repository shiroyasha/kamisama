require "ffi"

module Kamisama
  class ProcessCtrl
    SIGINT = 2
    SIGTERM = 15

    module LibC
      PR_SET_NAME = 15
      PR_SET_PDEATHSIG = 1

      extend FFI::Library
      ffi_lib "c"
      attach_function :prctl, [:int, :long, :long, :long, :long], :int
    end

    def self.set_process_name(process_name)
      # The process name is max 16 characters, so get the first 16, and if it is
      # less pad with spaces to avoid formatting wierdness
      process_name = "%-16.16s" % name

      LibC.prctl(LibC::PR_SET_NAME, process_name, 0, 0, 0)
    end

    def self.set_parent_death_signal(signal)
      case signal
      when :sigint
        LibC.prctl(LibC::PR_SET_PDEATHSIG, SIGINT, 0, 0, 0)
      when :sigterm
        LibC.prctl(LibC::PR_SET_PDEATHSIG, SIGTERM, 0, 0, 0)
      else
        raise "Unrecognized signal '#{signal.inspect}'"
      end
    end
  end
end
