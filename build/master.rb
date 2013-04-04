
Dir.chdir("../") do
	require './lib/relaxo/version'

	Gem::Specification.new do |s|
		s.name = "relaxo"
		s.version = Relaxo::VERSION::STRING
		s.author = "Samuel Williams"
		s.email = "samuel@oriontransfer.org"
		s.homepage = "http://www.codeotaku.com/projects/relaxo"
		s.platform = Gem::Platform::RUBY
		s.summary = "Relaxo is a helper for loading and working with CouchDB."
		s.files = FileList["{bin,lib,test}/**/*"] + ["rakefile.rb", "Gemfile", "README.md"]

		s.executables << 'relaxo'

		s.add_dependency("json", "~> 1.7.3")
		s.add_dependency("rest-client", "~> 1.6.7")

		s.has_rdoc = "yard"
	end
end
