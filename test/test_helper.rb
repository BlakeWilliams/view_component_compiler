# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "view_component_compiler"

# # Configure Rails Environment
# ENV["RAILS_ENV"] = "test"
#
# require File.expand_path("../sandbox/config/environment.rb", __FILE__)
# require "rails/test_help"

require "minitest/autorun"
