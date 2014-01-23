require_relative '../setup'
require_relative 'method_profile/test_class'

class MethodProfileTest < Minitest::Test
  def test_profile_a_single_method
    assert_match(/Started profiling TestClass#fast/,
      pry_eval('profile-method TestClass#fast'))

    pry_eval('TestClass.new.fast')
    assert_match(/\| #fast /, pry_eval('profile-method --stop'))
  end

  def test_no_arguments_given
    assert_match(/Usage:/, pry_eval('profile-method'))
  end

  def test_no_arguments_given_when_profiling
    pry_eval('profile-method TestClass#fast')
    assert_match(/Simultaneous profiling is not possible/,
      pry_eval('profile-method'))
  end

  def test_impossibility_of_simultaneous_profiling
    pry_eval('profile-method TestClass#fast')
    assert_match(/Simultaneous profiling is not possible/,
      pry_eval('profile-method TestClass#medium'))
  end

  def test_profiling_can_be_stopped
    pry_eval('profile-method TestClass#fast')
    assert_match(/Stopped profiling/, pry_eval('profile-method --stop'))
  end

  def test_profiling_cannot_be_stopped_when_nothing_was_profiled
    assert_match(/Nothing to stop/, pry_eval('profile-method --stop'))
  end

  def test_displaying_of_the_method_being_profiled
    assert_match(/Not profiling anything at the moment/,
      pry_eval('profile-method --current'))

    pry_eval('profile-method TestClass#fast')
    assert_match(/Profiling the .+ method/,
      pry_eval('profile-method --current'))
  end

  def test_freak_out_on_classes
    klass = Class.new
    assert_match(/The command cannot profile classes/,
      pry_eval('profile-method klass'))
  end

  def test_freak_out_on_nonexistent_methods
    assert_match(/The .+ method does not exist/, pry_eval('profile-method xxx'))
  end

  def test_the_last_benchmark_is_stored_in_memory
    pry_eval('TestClass.new.fast')
    assert_match(/\| #fast /, pry_eval('profile-method --last-result'))
  end

  def test_the_last_benchmark_is_nil_when_nothing_was_benchmarked
    assert_nil pry_eval('profile-method --last-result')
  end
end
