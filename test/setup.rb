# The main testing framework.
require 'minitest/autorun'

# Use it when it is fixed.
# require 'minitest/ansi'
# MiniTest::ANSI.use!

# We do not require Pry in the plugin's code, but we need it here.
# The order matters, it must be required *before* 'bundler/setup'.
require 'pry'

# Require the plugin's code.
require 'bundler/setup'
Bundler.require :default, :test

# Bring in the helpers (namely, we need "pry_eval").
require 'pry/test/helper'

# Must have if your code must be tested against different Ruby implementations.
system 'ruby --version'
