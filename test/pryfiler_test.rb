require_relative 'setup'

class PryfilerTest < Minitest::Test
  class Lobotomite
    def bark; :bark end
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

  def test_set_profiled_method_with_method
    assert_instance_of(Pry::Method,
      @pryfiler.set_profiled_method('Array#size', @pry))
  end

  def test_set_profiled_method_with_class
    assert_instance_of(Pry::WrappedModule,
      @pryfiler.set_profiled_method('Lobotomite', @pry))
  end

  def test_set_profiled_method_with_module
    assert_instance_of(Pry::WrappedModule,
      @pryfiler.set_profiled_method('Ghoul', @pry))
  end

  def test_running_by_default
    refute @pryfiler.running, @pryfiler.inspect
  end

  def test_running_after_setting_profiled_method
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    refute @pryfiler.running, @pryfiler.inspect
  end

  def test_start
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    @pryfiler.start
    assert @pryfiler.running, @pryfiler.inspect
  end

  def test_double_start
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    2.times {
      @pryfiler.start
      assert @pryfiler.running, @pryfiler.inspect
    }
  end

  def test_start_without_profiled_method
    refute @pryfiler.start
    refute @pryfiler.running, @pryfiler.inspect
  end

  def test_abort
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    @pryfiler.start
    @pryfiler.abort

    refute @pryfiler.running, @pryfiler.inspect
  end

  def test_abort_without_start
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    @pryfiler.abort
    refute @pryfiler.running, @pryfiler.inspect
  end

  def test_abort_report
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    @pryfiler.abort
    refute @pryfiler.report, @pryfiler.inspect
  end

  def test_stop
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    @pryfiler.start
    @pryfiler.stop
    assert_instance_of PryProfiler::Pryfiler::EmptyReport, @pryfiler.report
  end

  def test_stop_without_start
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    @pryfiler.stop
    refute @pryfiler.running, @pryfiler.inspect
  end

  def test_method_name
    @pryfiler.set_profiled_method('Lobotomite#bark', @pry)
    assert_equal 'PryfilerTest::Lobotomite#bark', @pryfiler.method_name
  end

  def test_report
    refute @pryfiler.report, @pryfiler.inspect
  end
end
