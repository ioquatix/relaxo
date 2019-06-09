
require_relative 'lib/relaxo/version'

Gem::Specification.new do |spec|
	spec.name          = "relaxo"
	spec.version       = Relaxo::VERSION
	spec.authors       = ["Samuel Williams"]
	spec.email         = ["samuel.williams@oriontransfer.co.nz"]
	spec.description   = <<-EOF
		Relaxo provides a set of tools and interfaces for interacting with CouchDB.
		It aims to be as simple and efficient as possible while still improving the
		usability of various CouchDB features.
	EOF
	spec.summary       = %q{Relaxo is a helper for loading and working with CouchDB.}
	spec.homepage      = ""
	spec.license       = "MIT"

	spec.files         = `git ls-files`.split($/)
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]
	
	spec.add_dependency "rugged"
	spec.add_dependency "console"
	
	spec.add_development_dependency "covered"
	spec.add_development_dependency "rspec", "~> 3.6"
	spec.add_development_dependency "bundler", "~> 1.3"
	spec.add_development_dependency "rake"
end
