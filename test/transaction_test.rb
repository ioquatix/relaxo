#!/usr/bin/env ruby

require 'helper'

require 'relaxo'
require 'relaxo/transaction'

class TransactionTest < Test::Unit::TestCase
	def setup
		@connection = Relaxo::Connection.new(TEST_DATABASE_HOST)
		@database = Relaxo::Database.new(@connection, TEST_DATABASE_NAME)
		
		if @database.exist?
			@database.delete!
		end
		
		@database.create!
	end
	
	def test_adding_documents
		documents = @database.transaction do |txn|
			10.times do |i|
				txn.save({:i => i})
			end
		end
		
		# We got 10 document IDs back
		assert_equal 10, documents.size
	end
	
	def test_abortion
		all_documents = @database.documents
		
		documents = @database.transaction do |txn|
			10.times do |i|
				txn.save({:i => i})
				
				txn.abort! if i == 5
			end
		end
		
		assert_equal nil, documents
		assert_equal all_documents, @database.documents
	end
	
	def test_deletion
		documents = @database.transaction do |txn|
			3.times do |i|
				txn.save({:i => i})
			end
		end
		
		@database.transaction do |txn|
			documents.each do |document|
				txn.delete(document)
			end
		end
		
		documents.each do |document|
			assert_equal false, @database.id?(document[Relaxo::ID])
		end
	end
end
