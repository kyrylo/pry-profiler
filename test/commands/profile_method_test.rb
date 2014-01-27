require_relative '../setup'
require_relative 'profile_method/test_class'

class ProfileMethodTest < Minitest::Test
  def build_class_from(superclass)
    Class.new(superclass) do
      superclass.instance_methods(false).each { |method|
        define_method(method) do
          self.class.superclass.instance_method(method).bind(self).call
        end
      }
    end
  end

  def setup
    @t = pry_tester
    @t.context = binding # It was renamed to `push_binding` on Pry's master.

    @class = build_class_from(TestClass)
  end

  def test_profiling
    assert_match(/Started profiling #<.+>#slow/,
      @t.eval("profile-method @class#slow"))
    @t.eval("@class.new.slow", 'profile-method --stop')

    assert_match(/\| #slow /, @t.last_output)
    refute_match(/\| #fast /, @t.last_output)
    refute_match(/\| #medium /, @t.last_output)
  end

  def test_profiling_without_invocation
    @t.eval("profile-method @class#fast")
    assert_match(/The #<.+>#fast method was never invoked/,
      @t.eval('profile-method --stop'))
  end

  def test_stopping
    @t.eval("profile-method @class#medium")
    @t.eval('profile-method --stop')

    assert_match(/Started profiling #<.+>#medium/,
      @t.eval("profile-method @class#medium"))
  end

  def test_stopping_without_profiling
    assert_match(/Nothing to stop/, pry_eval('profile-method --stop'))
  end

  def test_zero_arguments
    assert_match(/Usage:/, pry_eval('profile-method'))
  end

  def test_simultaneous_profiling
    @t.eval("profile-method @class#fast")
    assert_match(/Simultaneous profiling is not possible/,
      @t.eval("profile-method @class#slow"))
  end

  def test_abortion
    @t.eval("profile-method @class#fast")
    assert_match(/Profiling was aborted./,
      @t.eval('profile-method --abort'))
  end

  def test_current_method
    @t.eval("profile-method @class#fast")
    assert_match(/Currently profiling #<.+>#fast/,
      @t.eval('profile-method --current'))
  end

  def test_current_method_without_profiling
    assert_match(/Not profiling anything at the moment/,
      pry_eval('profile-method --current'))
  end

  def test_class_profiling
    assert_match(/The `profile-method` command cannot profile classes/,
      pry_eval('profile-method Pry'))
  end

  def test_unknown_arguments
    assert_match(/Usage:/, pry_eval('profile-method qdwwdwq'))
    assert_match(/Usage:/, pry_eval('profile-method --foobar'))
  end

  def test_last_result
    @t.eval('profile-method @class#slow', '@class.new.slow')
    @t.eval('profile-method --stop')
    assert_match(/\| #slow /, @t.eval('profile-method --last-result'))
  end

  def test_last_result_without_profiling
    assert_match(/No last result/, @t.eval('profile-method --last-result'))
    @t.eval('profile-method @class#slow')
    assert_match(/No last result/, @t.eval('profile-method --last-result'))
  end
end
