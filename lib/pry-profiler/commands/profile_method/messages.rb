module PryProfiler
  class Command::ProfileMethod < Pry::ClassCommand
    module Messages

      private

      def abort_msg
        <<MSG
Profiling aborted.
The results are neither stored nor displayed.
MSG
      end

      def current_msg
        <<MSG
Currently profiling #{ pryfiler.method_name }.
MSG
      end

      def no_last_result_msg
        <<MSG
No last result.
Profile something first with
`profile-method YourClass#your_method`
MSG
      end

      def simultaneous_profiling_msg
        <<MSG
Simultaneous profiling is not possible.
You are already profiling #{ pryfiler.method_name }.
`profile-method --stop` to stop profiling. Then, give it a new go.

MSG
      end

      def no_stop_msg
        <<MSG
Nothing to stop.
MSG
      end

      def not_profiling_msg
        <<MSG
Not profiling anything at the moment.
MSG
      end

      def profiling_started_msg
        <<MSG
Started profiling #{ pryfiler.method_name }.
Perform some work and then write `profile-method --stop`
to display the statistics about the method.
MSG
      end

      def classes_msg
        <<MSG
The `profile-method` command cannot profile classes!
MSG
      end

      def report_msg
        <<MSG
#{ pryfiler.report.to_s }
Try again later or use
`profile-method --abort` to abort profiling.
MSG
      end
    end
  end
end
