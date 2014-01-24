module PryProfiler
  class ObservableClass
    def initialize(klass)
      @class = klass
    end

    def expose
      @class
    end

    def unwrap
      grouped_methods.each do |group|
        group[:context].class_eval do
          group[:methods].each { |method| Unwrapper.unwrap(method, self) }
        end
      end
    end

    private

    def singleton
      @class.singleton_class
    end

    def class_methods
      @class.methods(false)
    end

    def instance_methods
      @class.instance_methods(false) - private_instance_methods
    end

    def private_instance_methods
      @class.private_instance_methods(false)
    end

    def grouped_methods
      [{ context: singleton, methods: class_methods },
        { context: @class, methods: instance_methods }]
    end
  end
end
