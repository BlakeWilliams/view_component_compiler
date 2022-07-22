# frozen_string_literal: true

require "test_helper"
require "rails"
require "view_component"
require_relative "components/basic_component"

class TestViewComponentCompiler < ViewComponent::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::ViewComponentCompiler::VERSION
  end

  def test_it_does_something_useful
    method_container = Class.new

    method_container.module_eval <<~RUBY
      def some_template(locals)
        #{ViewComponentCompiler::Compiler.new("./test/components/basic_component.rb", BasicComponent).compile}
      end
    RUBY

    locals = { name: "Fox Mulder" }
    render_instance = method_container.new
    render_instance.instance_variable_set(:@output_buffer, ActionView::OutputBuffer.new)
    output = render_instance.some_template(locals)

    assert_equal "<h1>Hello Fox Mulder</h1>\n", output
  end
end
