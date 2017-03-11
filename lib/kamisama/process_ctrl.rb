require "ffi"

module Kamisama
  class ProcessCtrl
    module LibC
      PR_SET_NAME = 15
      PR_SET_PDEATHSIG = 1

      SIGINT = 2
      SIGTERM = 15

      extend FFI::Library
      ffi_lib "c"
      attach_function :prctl, [:int, :long, :long, :long, :long], :int
    end

    class << self
      def set_process_name(process_name)
        # The process name is max 16 characters, so get the first 16, and if it is
        # less pad with spaces to avoid formatting wierdness
        process_name = "%-16.16s" % name

        LibC.prctl(LibC::PR_SET_NAME, process_name, 0, 0, 0)
      end

      def set_parent_death_signal(signal)
        LibC.prctl(LibC::PR_SET_PDEATHSIG, signal, 0, 0, 0)
      end
    end
  end
end
