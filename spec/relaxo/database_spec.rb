#!/usr/bin/env ruby

require 'relaxo'
require 'relaxo/attachments'

require_relative 'spec_helper'

RSpec.describe Relaxo::Database do
	before :all do
		@connection = Relaxo::Connection.new(TEST_DATABASE_HOST)
		@database = Relaxo::Database.new(@connection, TEST_DATABASE_NAME)
		
		if @database.exist?
			@database.delete!
		end
		
		@database.create!
	end
	
	it "should connect and add a document" do
		expect(@database.id?('foobar')).to be false
		
		document = {'animal' => 'Cat', 'name' => 'Seifa'}
		
		@database.save(document)
		
		id = document[Relaxo::ID]
		expect(@database.id?(id)).to be true
		
		copy = @database.get(id)
		document.each do |key, value|
			expect(copy[key]).to be == value
		end
	end
	
	it "should save an attachment" do
		document = {
			Relaxo::ATTACHMENTS => {
				"foo.txt" => {
					"content_type" => "text\/plain",
					"data" => "VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ="
				}
			}
		}
		
		result = @database.save(document)
		expect(result['ok']).to be true
		
		document = @database.get(document[Relaxo::ID])
		expect(document[Relaxo::ATTACHMENTS].size).to be == 1
	end
end
