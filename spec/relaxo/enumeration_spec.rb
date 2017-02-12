
require 'relaxo'

RSpec.shared_context "test records" do
	let(:database_path) {File.join(__dir__, 'test')}
	let(:database) {Relaxo.connect(database_path)}
	
	let(:prefix) {"records"}
	
	before(:each) do
		FileUtils.rm_rf(database_path)
		
		database.commit(message: "Create Sample Data") do |dataset|
			20.times do |i|
				object = dataset.append("good-#{i}")
				dataset.write("#{prefix}/#{i}", object)
			end
			
			10.times do |i|
				object = dataset.append("bad-#{i}")
				dataset.write("#{prefix}/subdirectory/#{i}", object)
			end
		end
	end
end

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