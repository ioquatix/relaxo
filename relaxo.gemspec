# frozen_string_literal: true

require_relative "lib/relaxo/version"

Gem::Specification.new do |spec|
	spec.name = "relaxo"
	spec.version = Relaxo::VERSION
	
	spec.summary = "Relaxo is versioned document database built on top of git."
	spec.authors = ["Samuel Williams", "Huba Nagy", "Olle Jonsson"]
	spec.license = "MIT"
	
	spec.cert_chain  = ['release.cert']
	spec.signing_key = File.expand_path('~/.gem/release.pem')
	
	spec.homepage = "https://github.com/ioquatix/relaxo"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
		"source_code_uri" => "https://github.com/ioquatix/relaxo.git",
	}
	
	spec.files = Dir.glob(['{lib}/**/*', '*.md'], File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 3.1"
	
	spec.add_dependency "console"
	spec.add_dependency "rugged"
end
