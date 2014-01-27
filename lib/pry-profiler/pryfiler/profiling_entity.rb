module PryProfiler
  class Pryfiler
    class ProfilingEntity
      def initialize(entity)
        @entity = entity
      end

      def class?
        @entity.class == Pry::WrappedModule
      end

      def method?
        @entity.class == Pry::Method
      end
    end
  end
end
