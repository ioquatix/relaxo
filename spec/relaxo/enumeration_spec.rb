
require_relative 'test_records'

RSpec.describe Relaxo::Dataset do
	include_context "test records"
	
	it "should enumerate all documents" do
		records = []
		
		database.current do |dataset|
			records = dataset.each(prefix).to_a
		end
		
		expect(records.count).to be 20
	end
end

RSpec.describe Relaxo::Changeset do
	include_context "test records"
	
	it "should enumerate all documents" do
		records = []
		
		database.commit(message: "Testing Enumeration") do |dataset|
			records = dataset.each(prefix).to_a
		end
		
		expect(records.count).to be 20
	end
end