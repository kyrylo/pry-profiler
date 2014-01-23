module PryProfiler
  class Pryfiler

    attr_accessor :_pry_

    attr_reader :method, :running

    alias_method :running?, :running

    def initialize
      @running  = false
      @profiler = nil
      @method   = nil
      @pry      = nil
      @report   = nil
    end

    def method=(method_name)
      unless _pry_
        fail(StandardError,
          'The _pry_ property is `nil`. Set it before setting the method')
      end

      @method = lookup_method(method_name, _pry_)
    end

    def start
      if @method.class == Pry::Method && !@running
        @profiler = MethodProfiler.observe(@method.owner)
        @running = true
      else
        false
      end
    end

    def stop
      @running = false
      @report = @profiler.report
      @profiler = nil
      true
    end

    def method_name
      @method.name_with_owner
    end

    def report
      @profiler.report
    end

    private

    def lookup_method(name, context)
      Pry::CodeObject.lookup(name, context)
    end

  end
end
