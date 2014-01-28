module PryProfiler
  Command = Class.new

  class Command::ProfileMethod < Pry::ClassCommand
    match 'profile-method'
    description 'Profile methods!'

    banner <<-'BANNER'
      Usage: profile-method [METH]
    BANNER

    def options(opt)
      opt.on(:s, :stop,
        'Stop profiling and output the statistics',
        argument: false)
      opt.on(:a, :abort,
        'Force stop profiling (statistics is not displayed)',
        argument: false)
      opt.on(:c, :current,
        'Show the method being profiled at the moment',
        argument: false)
      opt.on(:l, :'last-result',
        'Output the statistics of the last benchmark',
        argument: false)
    end

    def process
      if pryfiler.running
        perform_prelude
      else
        perform_postlude
      end
    end

    private

    def perform_prelude
      if args.empty?
        if opts.stop?
          pryfiler.stop
          output.puts(state.last_result = report_msg)
          reset_pryfiler
        elsif opts.abort?
          pryfiler.stop
          output.puts "Profiling aborted.\n" +
            'The results are neither stored nor displayed.'
          reset_pryfiler
        elsif opts.current?
          output.puts "Currently profiling #{ pryfiler.method_name }."
        elsif opts.last_result?
          if state.last_result
            output.puts state.last_result
          else
            output.puts "No last result.\n" +
              "Profile something first with\n" +
              '`profile-method YourClass#your_method`'
          end
        end
      else
        output.puts "Simultaneous profiling is not possible.\n" +
          "You are already profiling #{ pryfiler.method_name }.\n" +
          '`profile-method --stop` to stop profiling. Then, give it a new go.'
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
          output.puts "Started profiling #{ pryfiler.method_name }.\n" +
            "Perform some work and then write `profile-method --stop`\n" +
            'to display the statistics about the method.'
        elsif pryfiler.profiling_entity.class?
          output.puts 'The `profile-method` command cannot profile classes!'
        else
          output.puts(help)
        end
      end
    end

    def report_msg
      [pryfiler.report.to_s,
        'Try again later or use',
        '`profile-method --abort` to abort profiling.'].join("\n")
    end

    def reset_pryfiler
      state.pryfiler = Pryfiler.new
    end

    def pryfiler
      state.pryfiler ||= Pryfiler.new
    end
  end

  Pry::Commands.add_command(PryProfiler::Command::ProfileMethod)
end
