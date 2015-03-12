lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "takky"

Gem::Specification.new do |spec|
  spec.name          = "takky"
  spec.version       = Takky::VERSION
  spec.authors       = ["Jon-Michael Deldin"]
  spec.email         = ["dev@jmdeldin.com"]

  spec.summary       = "Asynchronous model upload/attachment gem."
  # spec.description
  spec.homepage      = "https://github.com/jmdeldin/takky"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ /test/ }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
