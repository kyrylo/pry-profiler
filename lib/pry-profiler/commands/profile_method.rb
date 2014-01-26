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
      opt.on :a, :abort, 'Force stop profiling (results are not displayed)', argument: false
      opt.on :c, :current, 'Show the method being profiled', argument: false
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
          report_msg = [
            pryfiler.report.to_s,
            "Use `profile-method --abort` to stop profiling."
          ].join("\n")
          output.puts report_msg
          state.pryfiler = PryProfiler::Pryfiler.new
        elsif opts.abort?
          pryfiler.stop
          output.puts "Profiling was aborted. The results will not be displayed."
          state.pryfiler = PryProfiler::Pryfiler.new
        elsif opts.current?
          output.puts "Currently profiling #{ pryfiler.method_name }."
        end
      else
        output.puts "[Profiler]: Simultaneous profiling is not possible.\n" +
          "            You are already profiling #{ pryfiler.method_name }.\n" +
          '            `profile-method --stop` to stop profiling. Then start a new one.'
      end
    end

    def perform_postlude
      if opts.stop?
        output.puts 'Nothing to stop.'
      elsif opts.current?
        output.puts 'Not profiling anything at the moment.'
      elsif args.empty?
        output.puts(help)
      else
        pryfiler.set_profiled_method(args.first, _pry_)
        if pryfiler.start
          output.puts "[Profiler]: Started profiling #{ pryfiler.method_name }...\n" +
            '            Do some work and then write `profile-method --stop`.'
        else
          output.puts "The `profile-method` command cannot profile classes!"
        end
      end
    end
  end

  Pry::Commands.add_command(PryProfiler::Command::ProfileMethod)
end
