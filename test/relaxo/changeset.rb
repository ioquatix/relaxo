# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2019, by Samuel Williams.

require 'relaxo/test_records'

describe Relaxo::Changeset do
	include_context Relaxo::TestRecords
	
	it "should enumerate all documents including writes" do
		records = []
		
		database.commit(message: "Testing Enumeration") do |dataset|
			5.times do |i|
				object = dataset.append("extra-#{i}")
				dataset.write("#{prefix}/extra-#{i}", object)
			end
			
			expect(dataset.exist?("#{prefix}/extra-0")).to be_truthy
			
			records = dataset.each(prefix).to_a
		end
		
		expect(records.count).to be == 25
	end
	
	it "should enumerate all documents excluding deletes" do
		records = database.commit(message: "Testing Enumeration") do |dataset|
			5.times do |i|
				dataset.delete("#{prefix}/#{i}")
			end
			
			expect(dataset.exist?("#{prefix}/0")).to be_falsey
			
			dataset.each(prefix).to_a
		end
		
		expect(records.count).to be == 15
	end
	
	let(:author) do
		{name: 'Testing McTestface', email: 'testing@testing.com'}
	end
	
	it "can use specified author" do
		database.commit(message: "Testing Enumeration", author: author) do |dataset|
			object = dataset.append("Hello World!")
			dataset.write("hello.txt", object)
		end
		
		commit = database.head.target
		expect(commit.author).to have_keys(
			name: be == 'Testing McTestface',
			email: be == 'testing@testing.com',
		)
	end
end
