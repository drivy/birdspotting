
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "migration_helpers/version"

Gem::Specification.new do |spec|
  spec.name          = "migration_helpers"
  spec.version       = MigrationHelpers::VERSION
  spec.authors       = ["Drivy", "Howard Wilson", "David Bourguignon"]
  spec.email         = ["oss@drivy.com"]

  spec.summary       = %q{Rails migration helpers.}
  spec.homepage      = "https://github.com/drivy/migration_helpers"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "simplecov"
end
