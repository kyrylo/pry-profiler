require_relative 'setup'

class PryfilerTest < Minitest::Test
  class Lobotomite
    def bark; :bar end
  end

  module Ghoul
    def woof; :woof end
  end

  def setup
    @pryfiler = PryProfiler::Pryfiler.new
    @pry = Pry.new

    # This is the old way. On Pry `master` we don't need this trick: it will
    # assume the context automatically. That is, replace this with simple:
    #   Pry.new
    @pry.binding_stack = [binding]
  end

  def test_set_profiled_method
    assert_instance_of(Pry::Method,
      @pryfiler.set_profiled_method('Array#size', @pry))
    assert_instance_of(Pry::WrappedModule,
      @pryfiler.set_profiled_method('Lobotomite', @pry))
    assert_instance_of(Pry::WrappedModule,
      @pryfiler.set_profiled_method('Ghoul', @pry))
  end
end
