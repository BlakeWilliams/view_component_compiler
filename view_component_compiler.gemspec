# frozen_string_literal: true

require_relative "lib/view_component_compiler/version"

Gem::Specification.new do |spec|
  spec.name = "view_component_compiler"
  spec.version = ViewComponentCompiler::VERSION
  spec.authors = ["Blake Williams"]
  spec.email = ["blake@blakewilliams.me"]

  spec.description = "A compiler for view components, enabling even faster rendering."
  spec.summary = spec.description
  spec.homepage = "https://github.com/blakewilliams/view_component_compiler"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/blakewilliams/view_component_compiler"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.require_paths = ["lib"]

  spec.add_dependency "view_component", "~> 2.61.0"
  spec.add_dependency "syntax_tree", "~> 3.2.0"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
