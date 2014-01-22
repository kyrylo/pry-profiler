module PryProfiler
  Command = Class.new

  class Command::ProfileMethod < Pry::ClassCommand
    match 'profile-method'
    description 'Profile methods!'

    banner <<-'BANNER'
      Usage: profile-method [METH]
    BANNER

    def process
      binding.pry
    end
  end

  Pry::Commands.add_command(PryProfiler::Command::ProfileMethod)
end
