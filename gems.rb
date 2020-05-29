source 'https://rubygems.org'

# Specify your gem's dependencies in relaxo.gemspec
gemspec

group :test do
	gem 'benchmark-ips'
	gem 'ruby-prof'
end
