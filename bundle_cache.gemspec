# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'bundle_cache/version'

Gem::Specification.new do |spec|
  spec.name          = "bundle_cache"
  spec.version       = BundleCache::VERSION
  spec.authors       = ["Eric Barendt", "Matias Korhonen"]
  spec.email         = ["eric.barendt@infogroup.com", "me@matiaskorhonen.fi"]
  spec.description   = %q{Caches bundled gems on S3}
  spec.summary       = %q{Speed up your build on Travis CI by caching bundled gems in an S3 bucket}
  spec.homepage      = "https://github.com/data-axle/bundle_cache"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "s3", "~> 0.3"
  spec.add_dependency "bundler"

  spec.add_development_dependency "bundler", "~> 1.5", ">= 0"
  spec.add_development_dependency "rake"
end
