module PryProfiler
  Command = Class.new

  class Command::ProfileMethod < Pry::ClassCommand
    match 'profile-method'
    description 'Profile methods!'

    banner <<-'BANNER'
      Usage: profile-method [METH]
    BANNER

    class NoProfiler
      def start
        false
      end
    end

    def process
      if args.empty?
        output.puts help
      else
        state.profiler = PryProfiler::Pryfiler.new(args.first, _pry_)
        if state.profiler.method.class == Class
          output.puts "The command cannot profile classes"
        end
      end
      # if opts.stop? && state[:profiling]
      #   state
      # elsif args.first && state[:profiling]
      #   output.puts "[Profiler]: Simultaneous profiling is not possible.\n" +
      #     "             You are already profiling #{ state[:method].name_with_owner }. " +
      #     "             Stop profiling with `profile-method --stop` and then start a new one."
      # else


      # end
      # if state.profiler.start
      #   output.puts "[Profiler]: Started profiling #{ state.profiler.method_name }...\n" +
      #     "            Do some work and then write `profile-method --stop`."
      # else
      #   state.profiler = NoProfiler.new
      #   output.puts "NOOOO"
      # end

    end

  end

  Pry::Commands.add_command(PryProfiler::Command::ProfileMethod)
end
