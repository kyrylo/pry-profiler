module PryProfiler
  class Pryfiler
    attr_reader :report, :running

    def initialize
      @running = false
    end

    def set_profiled_method(method_name, context)
      @method = Pry::CodeObject.lookup(method_name, context)
    end

    def start
      if !running && @method.class != Pry::WrappedModule
        @observable_class = ObservableClass.new(@method.owner)
        @profiler = MethodProfiler.observe(@observable_class.expose)
        @running = true
      end
    end

    def stop
      @report = report_current_method
      @observable_class.unwrap
    ensure
      @running = false
    end

    def method_name
      @method.name_with_owner
    end

    def profiling_entity
      ProfilingEntity.new(@method)
    end

    private

    def report_current_method
      method_table = @profiler.report.instance_variable_get(:@data)
      desired_method = '#' + @method.name
      desired_method_data = method_table.find do |h|
        h[:method] == desired_method
      end
      if desired_method_data
        MethodProfiler::Report.new([desired_method_data], desired_method)
      else
        EmptyReport.new(method_name)
      end
    end
  end
end
