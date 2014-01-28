module PryProfiler
  Command = Class.new

  require_relative 'profile_method/messages'

  class Command::ProfileMethod < Pry::ClassCommand
    include Messages

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
          output.puts(report_msg)
          unless pryfiler.running
            state.last_result = report_msg
            reset_pryfiler
          end
        elsif opts.abort?
          pryfiler.abort
          output.puts(abort_msg)
          reset_pryfiler
        elsif opts.current?
          output.puts(current_msg)
        elsif opts.last_result?
          if state.last_result
            output.puts state.last_result
          else
            output.puts(no_last_result_msg)
          end
        end
      else
        output.puts(simultaneous_profiling_msg)
      end
    end

    def perform_postlude
      if opts.stop?
        output.puts(no_stop_msg)
      elsif opts.current?
        output.puts(not_profiling_msg)
      elsif opts.last_result?
        if state.last_result
          output.puts state.last_result
        else
          output.puts(no_last_result_msg)
        end
      elsif args.empty?
        output.puts(help)
      else
        pryfiler.set_profiled_method(args.first, _pry_)
        if pryfiler.profiling_entity.method?
          pryfiler.start
          output.puts(profiling_started_msg)
        elsif pryfiler.profiling_entity.class?
          output.puts(classes_msg)
        else
          output.puts(help)
        end
      end
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
