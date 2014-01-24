module PryProfiler
  class ObservableClass
    class Unwrapper
      def self.unwrap(method, context)
        context.class_eval do
          if method =~ /_with_profiling\z/
            remove_method method
          elsif method =~ /_without_profiling\z/
            alias_method method.to_s.sub(/_without_profiling\z/, ''), method
            remove_method method
          end
        end
      end
    end
  end
end
