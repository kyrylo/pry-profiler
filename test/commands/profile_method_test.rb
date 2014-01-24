# -*- coding: utf-8 -*-

require_relative '../setup'
require_relative 'profile_method/test_class'

class ProfileMethodTest < Minitest::Test
  def setup
    @t = pry_tester
  end

  def teardown
    @t.eval('profile-method --stop')
  end

  def test_profile_a_single_method
    assert_match(/Started profiling TestClass#slow/,
      @t.eval('profile-method TestClass#slow'))
    @t.eval('TestClass.new.slow', 'profile-method --stop')

    assert_match(/\| #slow /, @t.last_output)
    refute_match(/\| #fast /, @t.last_output)
    refute_match(/\| #medium /, @t.last_output)
  end

  def test_informing_that_the_method_being_profiled_was_never_invoked
    @t.eval('profile-method TestClass#fast')
    assert_match(/The TestClass#fast method was never invoked/,
      @t.eval('profile-method --stop'))
  end

  def test_profiling_can_be_applied_twice_to_the_same_method
    @t.eval('profile-method TestClass#medium')
    @t.eval('profile-method --stop')

    assert_match(/Started profiling TestClass#medium/,
      @t.eval('profile-method TestClass#medium'))
  end

  def test_no_arguments_given
    assert_match(/Usage:/, pry_eval('profile-method'))
  end

  def test_no_arguments_given_when_profiling
    skip
    pry_eval('profile-method TestClass#fast')
    assert_match(/Simultaneous profiling is not possible/,
      pry_eval('profile-method'))
  end

  def test_impossibility_of_simultaneous_profiling
    skip
    pry_eval('profile-method TestClass#fast')
    assert_match(/Simultaneous profiling is not possible/,
      pry_eval('profile-method TestClass#medium'))
  end

  def test_profiling_can_be_stopped
    skip
    pry_eval('profile-method TestClass#fast')
    assert_match(/Stopped profiling/, pry_eval('profile-method --stop'))
  end

  def test_profiling_cannot_be_stopped_when_nothing_was_profiled
    skip
    assert_match(/Nothing to stop/, pry_eval('profile-method --stop'))
  end

  def test_displaying_of_the_method_being_profiled
    skip
    assert_match(/Not profiling anything at the moment/,
      pry_eval('profile-method --current'))

    pry_eval('profile-method TestClass#fast')
    assert_match(/Profiling the .+ method/,
      pry_eval('profile-method --current'))
  end

  def test_freak_out_on_classes
    skip
    klass = Class.new
    assert_match(/The command cannot profile classes/,
      pry_eval('profile-method klass'))
  end

  def test_freak_out_on_nonexistent_methods
    skip
    assert_match(/The .+ method does not exist/, pry_eval('profile-method xxx'))
  end

  def test_the_last_benchmark_is_stored_in_memory
    skip
    pry_eval('TestClass.new.fast')
    assert_match(/\| #fast /, pry_eval('profile-method --last-result'))
  end

  def test_the_last_benchmark_is_nil_when_nothing_was_benchmarked
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
