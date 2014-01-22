class TestClass
  def fast
    sleep 0.01
    :foo
  end

  def medium
    sleep 1
    :bar
  end

  def slow
    sleep 3
    :baz
  end
end
