
require_relative 'test_records'

RSpec.describe Relaxo::Changeset do
	include_context "test records"
	
	it "should enumerate all documents including writes" do
		records = []
		
		database.commit(message: "Testing Enumeration") do |dataset|
			5.times do |i|
				object = dataset.append("extra-#{i}")
				dataset.write("#{prefix}/extra-#{i}", object)
			end
			
			records = dataset.each(prefix).to_a
		end
		
		expect(records.count).to be 25
	end
	
	it "should enumerate all documents excluding deletes" do
		records = []
		
		database.commit(message: "Testing Enumeration") do |dataset|
			5.times do |i|
				dataset.delete("#{prefix}/#{i}")
			end
			
			records = dataset.each(prefix).to_a
		end
		
		expect(records.count).to be 15
	end
end
