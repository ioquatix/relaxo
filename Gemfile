source 'https://rubygems.org'

# Specify your gem's dependencies in relaxo.gemspec
gemspec

gem 'rugged', git: 'git://github.com/libgit2/rugged.git', submodules: true

group :development do
	gem "pry"
	gem "msgpack"
end

group :test do
	gem 'simplecov'
	gem 'coveralls', require: false
end
