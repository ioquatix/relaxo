source 'https://rubygems.org'

# Specify your gem's dependencies in relaxo.gemspec
gemspec

gem 'rugged', git: 'https://github.com/ioquatix/rugged.git', submodules: true

group :development do
	gem "pry"
	gem "msgpack"
end

group :test do
	gem 'benchmark-ips'
	gem 'ruby-prof'
	
	gem 'rack-test'
	gem 'simplecov'
	gem 'coveralls', require: false
end
