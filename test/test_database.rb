#!/usr/bin/env ruby

require 'helper'

require 'relaxo'

class DatabaseTest < Test::Unit::TestCase
	def setup
		@connection = Relaxo::Connection.new(TEST_DATABASE_HOST)
		@database = Relaxo::Database.new(@connection, TEST_DATABASE_NAME)
		
		if @database.exist?
			@database.delete!
		end
		
		@database.create!
	end
	
	def test_adding_document
		assert_equal false, @database.id?('foobar')
		
		document = {'animal' => 'Cat', 'name' => 'Seifa'}
		
		@database.save(document)
		
		id = document[Relaxo::ID]
		assert_equal true, @database.id?(id)
		
		copy = @database.get(id)
		document.each do |key, value|
			assert_equal value, copy[key]
		end
	end
end
