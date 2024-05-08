# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2019, by Samuel Williams.

require 'relaxo'
require 'tmpdir'

module Relaxo
	TemporaryDatabase = Sus::Shared("temporary database") do
		def around
			Dir.mktmpdir do |directory|
				@root = directory
				super
			end
		end
		
		let(:database_path) {@root}
		let(:database) {Relaxo.connect(database_path)}
	end
	
	TestRecords = Sus::Shared("test records") do
		include_context Relaxo::TemporaryDatabase
		
		let(:prefix) {"records"}
				
		def before
			super
			
			database.commit(message: "Create Sample Data") do |dataset|
				20.times do |i|
					object = dataset.append("good-#{i}")
					dataset.write("#{prefix}/#{i}", object)
				end
				
				10.times do |i|
					object = dataset.append("bad-#{i}")
					dataset.write("#{prefix}/subdirectory/#{i}", object)
				end
			end
		end
	end
end
