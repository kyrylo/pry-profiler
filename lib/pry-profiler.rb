require_relative 'pry-profiler/commands/profile_method'

module PryProfiler

  # The VERSION file must be in the root directory of the library.
  VERSION_FILE = File.expand_path('../../VERSION', __FILE__)

  VERSION = if File.exist?(VERSION_FILE)
              File.read(VERSION_FILE).chomp
            else
              '(could not find VERSION file)'
            end

end
