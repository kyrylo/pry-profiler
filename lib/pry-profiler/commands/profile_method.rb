module PryProfiler
  Command = Class.new

  class Command::ProfileMethod < Pry::ClassCommand
    match 'profile-method'
    description 'Profile methods!'

    banner <<-'BANNER'
      Usage: profile-method [METH]
    BANNER

    def options(opt)
      opt.on :s, :stop, 'Stop profiling and output results', argument: false
    end

    def pryfiler
      state.pryfiler ||= PryProfiler::Pryfiler.new
    end

    def process
      if pryfiler.running
        perform_prelude
      else
        perform_postlude
      end
    end

    def perform_prelude
      if args.empty?
        if opts.stop?
          pryfiler.stop
          output.puts '[Profiler]: ' + pryfiler.report
        end
      else
        output.puts '[Profiler]: Simultaneous profiling is not possible.\n' +
          "             You are already profiling #{ pryfiler.method_name }. " +
          '             Stop profiling with `profile-method --stop` and then start a new one.'
      end
    end

    def perform_postlude
      if args.empty?
        output.puts(help)
      else
        pryfiler.set_profiled_method(args.first, _pry_)

        if pryfiler.start
          output.puts "[Profiler]: Started profiling #{ pryfiler.method_name }...\n" +
            '            Do some work and then write `profile-method --stop`.'
        end
      end
    end
  end

  Pry::Commands.add_command(PryProfiler::Command::ProfileMethod)
end
