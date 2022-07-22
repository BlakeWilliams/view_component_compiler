# frozen_string_literal: true

require "syntax_tree"
require_relative "view_component_compiler/version"

module ViewComponentCompiler
  class Error < StandardError; end

  class Compiler
    def initialize(file, component)
      source = SyntaxTree.read(file)
      @root = SyntaxTree.parse(source)
      @component = component
    end

    def compile
      visitor = CompilerVisitor.new
      visitor.visit(@root)

      template_compiler = ViewComponent::Compiler.new(@component)
      template_source = template_compiler.send(:compiled_template, template_compiler.send(:templates)[0][:path])

      template_visitor = TemplateVisitor.new
      template_visitor.visit(SyntaxTree.parse(template_source))


      output = visitor.output
      output << "\n"
      output += template_visitor.output

      output
    end
  end

  class TemplateVisitor < SyntaxTree::BasicVisitor
    attr_reader :output

    def initialize
      @output = +"# Template start\n"
    end

    def visit_program(node)
      node.child_nodes.each { |c| visit(c) }
    end

    def visit_statements(node)
      node.child_nodes.each do |c|
        visit(c)
        @output << ";"
      end
    end

    def visit_assign(node)
      visit(node.target)
      @output << " = "
      visit(node.value)
    end

    def visit_field(node)
      node.child_nodes.each { |c| visit(c) }
    end

    def visit_call(node)
      node.child_nodes.each { |c| visit(c) }
    end

    def visit_string_literal(node)
      node.child_nodes.each { |c| visit(c) }
    end

    def visit_period(node)
      @output << "."
    end

    def visit_ident(node)
      @output << node.value.to_s
    end

    def visit_paren(node)
      @output << "("
      visit(node.contents)
      @output << ")"
    end

    def visit_var_ref(node)
      visit(node.value)
    end

    def visit_ivar(node)
      if node.value == "@output_buffer"
        @output << "@output_buffer"
      else
        name = node.value[1..-1]
        @output << "___vc_ivar_" + name
      end
    end

    def visit_tstring_content(node)
      @output << "\"#{node.value}\""
    end
  end

  class CompilerVisitor < SyntaxTree::BasicVisitor
    attr_reader :output

    def initialize
      super

      @ivars = +""
      @output = +""
      @modules = +""
      @modules << +""

      @post_modules = +""

      # cheat a small bit
      @post_modules << "___vcc_initializer.call(locals[:name])"
    end

    def output
      @output << @ivars
      @output << @modules

      @output << @post_modules
      @output
    end

    def visit_program(node)
      node.child_nodes.each { |c| visit(c) }
    end

    def visit_statements(node)
      node.child_nodes.each { |c| visit(c) }
    end

    def visit_comment(node); end

    def visit_class(node)
      class_name = node.constant.constant.value # TODO modules/namespace?
      @output << "# #{class_name}\n"
      node.bodystmt.child_nodes.each { |c| visit(c) }
    end

    def visit_def(node)
      visitor = MethodVisitor.new
      visitor.visit(node)
      @modules << visitor.output

      visitor.ivars.each do |ivar|
        @ivars << "___vc_ivar_#{ivar} = nil\n"
      end
    end
  end

  class MethodVisitor < SyntaxTree::BasicVisitor
    attr_reader :output, :ivars

    def initialize
      super
      @output = +""
      @ivars = []
      @is_initializer = false
    end

    def is_initializer?
      @is_initializer
    end

    def initialize_call
    end

    def visit_def(node)
      if node.name.is_a?(SyntaxTree::Ident) && node.name.value == "initialize"
        @is_initializer = true
        @output << "___vcc_initializer"
      else
        @output << "___vcc_method_"
        visit(node.name)
      end

      @output << " = -> "

      visit(node.params)
      @output << "{\n"
      visit(node.bodystmt)
      @output << "\n"
      @output << "}\n"
    end

    def visit_paren(node)
      @output << "("
      visit(node.contents)
      @output << ")"
    end

    def visit_params(node)
      node.child_nodes.each { |c| visit(c) }
    end

    def visit_bodystmt(node)
      # TODO handle rescue, handle else, handle ensure
      #
      visit(node.statements)
    end

    def visit_statements(node)
      node.body.each { |c| visit(c) }
    end

    def visit_assign(node)
      visit(node.target)
      @output << " = "
      visit(node.value)
    end

    def visit_var_field(node)
      visit(node.value)
    end

    def visit_ivar(node)
      name = node.value[1..-1]
      @ivars << name
      @output << "___vc_ivar_" + name
    end

    def visit_ident(node)
      @output << node.value.to_s
    end

    def visit_var_ref(node)
      visit(node.value)
    end
  end
end
