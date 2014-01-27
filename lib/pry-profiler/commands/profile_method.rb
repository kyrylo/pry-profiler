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
      opt.on :l, :'last-result', 'Output the results of the last benchmark', argument: false
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
          state.last_result = report_msg
          output.puts report_msg
          state.pryfiler = PryProfiler::Pryfiler.new
        elsif opts.abort?
          pryfiler.stop
          output.puts "Profiling was aborted. The results will not be displayed."
          state.pryfiler = PryProfiler::Pryfiler.new
        elsif opts.current?
          output.puts "Currently profiling #{ pryfiler.method_name }."
        elsif opts.last_result?
          if state.last_result
            output.puts state.last_result
          else
            output.puts "No last result. Profile something first with\n" +
              "`profile-method YourClass#your_method`"
          end
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
      elsif opts.last_result?
        if state.last_result
          output.puts state.last_result
        else
          output.puts "No last result. Profile something first with\n" +
            "`profile-method YourClass#your_method`"
        end
      elsif args.empty?
        output.puts(help)
      else
        pryfiler.set_profiled_method(args.first, _pry_)
        if pryfiler.profiling_entity.method?
          pryfiler.start
          output.puts "[Profiler]: Started profiling #{ pryfiler.method_name }...\n" +
            '            Do some work and then write `profile-method --stop`.'
        elsif pryfiler.profiling_entity.class?
          output.puts "The `profile-method` command cannot profile classes!"
        else
          output.puts(help)
        end
      end
    end
  end

  Pry::Commands.add_command(PryProfiler::Command::ProfileMethod)
end
