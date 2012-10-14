#!/usr/bin/env ruby

require 'helper'

require 'relaxo'

class ConnectionTest < Test::Unit::TestCase
	def setup
		@connection = Relaxo::Connection.new(TEST_DATABASE_HOST)
	end
	
	def test_info
		assert_equal Hash, @connection.info.class
	end
	
	def test_create_database
		database = Relaxo::Database.new(@connection, TEST_DATABASE_NAME)
		
		if database.exist?
			assert_equal Relaxo::SUCCESS, database.delete!
		end
		
		assert_equal Relaxo::SUCCESS, database.create!
		
		assert_includes TEST_DATABASE_NAME, @connection.databases
		
		assert_equal Relaxo::SUCCESS, database.delete!
	end
end
