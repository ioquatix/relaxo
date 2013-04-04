# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "relaxo"
  s.version = "0.1.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Samuel Williams"]
  s.date = "2012-07-10"
  s.email = "samuel.williams@oriontransfer.co.nz"
  s.executables = ["relaxo"]
  s.files = ["bin/relaxo", "lib/relaxo", "lib/relaxo/client.rb", "lib/relaxo/database.rb", "lib/relaxo/model.rb", "lib/relaxo/properties.rb", "lib/relaxo/recordset.rb", "lib/relaxo/server.rb", "lib/relaxo/version.rb", "lib/relaxo.rb", "README.md"]
  s.homepage = "http://www.oriontransfer.co.nz/gems/relaxo"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.23"
  s.summary = "Relaxo is a helper for loading and working with CouchDB."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<couchrest>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
    else
      s.add_dependency(%q<couchrest>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0"])
    end
  else
    s.add_dependency(%q<couchrest>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0"])
  end
end
