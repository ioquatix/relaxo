# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2017-2019, by Samuel Williams.

require 'relaxo/test_records'

describe Relaxo::Dataset do
	include_context Relaxo::TestRecords
	
	it "should enumerate all documents" do
		records = []
		
		database.current do |dataset|
			records = dataset.each(prefix).to_a
		end
		
		expect(records.count).to be == 20
	end
end

describe Relaxo::Changeset do
	include_context Relaxo::TestRecords
	
	it "should enumerate all documents" do
		records = []
		
		database.commit(message: "Testing Enumeration") do |dataset|
			records = dataset.each(prefix).to_a
		end
		
		expect(records.count).to be == 20
	end
end
