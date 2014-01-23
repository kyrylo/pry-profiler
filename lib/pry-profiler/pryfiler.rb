module PryProfiler
  class Pryfiler

    attr_reader :method

    def initialize(method_name, _pry_)
      @profiling = false
      @profiler  = nil
      @method    = lookup_method(method_name, _pry_)
    end

    def start
      if @method
        @profiling = true
        @profiler = MethodProfiler.observe(@method.owner)
      else
        false
      end
    end

    def stop
      puts @proifler.report
      @profiling = false
    end

    def profiling?
      @profiling
    end

    def method_name
      @method.name_with_owner
    end

    private

    def lookup_method(name, context)
      Pry::CodeObject.lookup(name, context)
    end

  end
end
