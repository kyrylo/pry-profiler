# -*- coding: utf-8 -*-

require_relative '../setup'
require_relative 'profile_method/test_class'

class ProfileMethodTest < Minitest::Test
  def setup
    @t = pry_tester
    @t.context = binding # It was renamed to `push_binding` on Pry's master.
    @class = Class.new(TestClass) do
      TestClass.instance_methods(false).each { |method|
        define_method(method) do
          self.class.superclass.instance_method(method).bind(self).call
        end
      }
    end
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
    skip
    assert_match(/Usage:/, pry_eval('profile-method qdwwdwq'))
    assert_match(/Usage:/, pry_eval('profile-method --foobar'))
  end

  def test_nonexistent_methods
    skip
    assert_match(/The .+ method does not exist/, pry_eval('profile-method xxx'))
  end

  def test_last_result
    skip
    pry_eval('#@class.new.fast')
    assert_match(/\| #fast /, pry_eval('profile-method --last-result'))
  end

  def test_last_result_without_profiling
    skip
    assert_nil pry_eval('profile-method --last-result')
  end

  # ~/code/pry-profiler[master]% pry                                                                                                                                                                                                ◾
  # [1] pry(main)> class Foo
  #              |   def bar
  #              |   end
  #              | end
  # => :bar
  # [2] pry(main)> profile-method Foo#bar
  # [Profiler]: Started profiling Foo#bar...
  #             Do some work and then write `profile-method --stop`.
  # [3] pry(main)> profile-method --stop
  # ArgumentError: Table must be an array of hashes or array of arrays
  # from /home/kyrylo/.gem/ruby/2.1.0/gems/hirb-0.7.1/lib/hirb/helpers/table.rb:166:in `initialize'

end
