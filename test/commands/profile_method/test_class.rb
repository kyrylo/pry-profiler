class TestClass
  def fast
    :foo
  end

  def medium
    fast
    :bar
  end

  def slow
    fast
    medium
    :baz
  end
end
