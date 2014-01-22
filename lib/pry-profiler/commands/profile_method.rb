module PryProfiler
  Command = Class.new

  class Command::ProfileMethod < Pry::ClassCommand
    match 'profile-method'
    description 'Profile methods!'

    banner <<-'BANNER'
      Usage: profile-method [METH]
    BANNER

    def process
      # if opts.stop? && state[:profiling]
      #   state
      # elsif args.first && state[:profiling]
      #   output.puts "[Profiler]: Simultaneous profiling is not possible.\n" +
      #     "             You are already profiling #{ state[:method].name_with_owner }. " +
      #     "             Stop profiling with `profile-method --stop` and then start a new one."
      # else


      state.profiler ||= PryProfiler::Pryfiler.new(args.first, _pry_)
      state.profiler.start
      output.puts "[Profiler]: Started profiling #{ state.profiler.method_name }...\n" +
        "            Do some work and then write `profile-method --stop`."

    end

  end

  Pry::Commands.add_command(PryProfiler::Command::ProfileMethod)
end
