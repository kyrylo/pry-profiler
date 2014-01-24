module PryProfiler
  class Pryfiler
    class EmptyReport
      def initialize(unfound_method)
        @unfound_method = unfound_method
      end

      def to_s
        "The #{ @unfound_method } method was not called at all."
      end
    end
  end
end
