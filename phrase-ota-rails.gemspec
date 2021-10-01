require_relative 'lib/phrase/ota/rails/version'

Gem::Specification.new do |spec|
  spec.name          = "phrase-ota-rails"
  spec.version       = Phrase::Ota::Rails::VERSION
  spec.authors       = ["Manuel Boy"]
  spec.email         = ["manuel.boy@phrase.com"]

  spec.summary       = %q{Phrase OTA for Rails i18n}
  spec.description   = %q{Phrase OTA for Rails i18n}
  spec.homepage      = "https://github.com/phrase/phrase-ota-rails"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "i18n"
  spec.add_runtime_dependency "faraday"
  spec.add_runtime_dependency "faraday_middleware"
end
