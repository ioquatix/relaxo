require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |task|
	task.rspec_opts = ["--require", "simplecov"] if ENV['COVERAGE']
end

task :default => :spec

task :console do
	require 'pry'
	
	require_relative 'lib/relaxo'
	
	DB = Relaxo.connect(File.join(__dir__, 'testdb'))
	
	Pry.start
end
