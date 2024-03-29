lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "birdspotting/version"

Gem::Specification.new do |spec|
  spec.name          = "birdspotting"
  spec.version       = Birdspotting::VERSION
  spec.authors       = [
    "Drivy",
    "Howard Wilson",
    "David Bourguignon",
    "Alice Morin",
    "Laurent Humez",
    "Rémy Hannequin",
    "Hugo Dornbierer",
  ]
  spec.email         = ["oss@drivy.com"]

  spec.summary       = "Rails migration helpers."
  spec.homepage      = "https://github.com/drivy/birdspotting"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "guard-rubocop"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec_junit_formatter"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "rubocop-rspec"
  spec.add_development_dependency "simplecov"

  spec.add_runtime_dependency "activerecord", ">= 6.0", "< 7.0"
end
