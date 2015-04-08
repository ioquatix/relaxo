#!/usr/bin/env ruby

require_relative 'spec_helper'

require 'relaxo'
require 'relaxo/transaction'

RSpec.describe Relaxo::Transaction do
	before :all do
		@connection = Relaxo::Connection.new(TEST_DATABASE_HOST)
		@database = Relaxo::Database.new(@connection, TEST_DATABASE_NAME)
		
		if @database.exist?
			@database.delete!
		end
		
		@database.create!
	end
	
	it "should create some documents" do
		documents = @database.transaction do |txn|
			10.times do |i|
				txn.save({:i => i})
			end
		end
		
		# We got 10 document IDs back
		expect(documents.size).to be == 10
	end
	
	it "should abort transaction" do
		all_documents = @database.documents
		
		documents = @database.transaction do |txn|
			10.times do |i|
				txn.save({:i => i})
				
				txn.abort! if i == 5
			end
		end
		
		expect(documents).to be nil
		expect(all_documents).to be == @database.documents
	end
	
	it "should delete some documents" do
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
			expect(@database.id?(document[Relaxo::ID])).to be false
		end
	end
end
