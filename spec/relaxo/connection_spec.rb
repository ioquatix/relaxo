#!/usr/bin/env ruby

require_relative 'spec_helper'

require 'relaxo'

RSpec.describe Relaxo::Connection do
	before :all do
		@connection = Relaxo::Connection.new(TEST_DATABASE_HOST)
	end
	
	it "should provide connection information hash" do
		expect(@connection.info).to be_kind_of Hash
	end
	
	it "should create test database" do
		database = Relaxo::Database.new(@connection, TEST_DATABASE_NAME)
		
		if database.exist?
			expect(database.delete!).to be == Relaxo::SUCCESS
		end
		
		expect(database.create!).to be == Relaxo::SUCCESS
		
		expect(@connection.databases).to be_include TEST_DATABASE_NAME
		
		expect(database.delete!).to be == Relaxo::SUCCESS
	end
end