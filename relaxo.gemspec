
require_relative "lib/relaxo/version"

Gem::Specification.new do |spec|
	spec.name = "relaxo"
	spec.version = Relaxo::VERSION
	
	spec.summary = "Relaxo is versioned document database built on top of git."
	spec.authors = ["Samuel Williams"]
	spec.license = "MIT"
	
	spec.homepage = "https://github.com/ioquatix/relaxo"
	
	spec.metadata = {
		"funding_uri" => "https://github.com/sponsors/ioquatix/",
	}
	
	spec.files = Dir.glob('{lib}/**/*', File::FNM_DOTMATCH, base: __dir__)
	
	spec.required_ruby_version = ">= 2.5"
	
	spec.add_dependency "console"
	spec.add_dependency "rugged"
	
	spec.add_development_dependency "bake"
	spec.add_development_dependency "bake-bundler"
	spec.add_development_dependency "bake-modernize"
	spec.add_development_dependency "bundler"
	spec.add_development_dependency "covered"
	spec.add_development_dependency "msgpack"
	spec.add_development_dependency "rspec", "~> 3.6"
end
