module PryProfiler
  class Pryfiler

    def initialize(method_name, _pry_)
      @method = Pry::CodeObject.lookup(method_name, _pry_)
      @profiling = false
      @profiler = nil
    end

    def start
      @profiling = true
      @profiler = MethodProfiler.observe(@method.owner)
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

  end
end
