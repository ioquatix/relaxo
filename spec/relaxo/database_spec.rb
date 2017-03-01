
require 'relaxo'

RSpec.describe Relaxo::Database do
	let(:database_path) {File.join(__dir__, 'test')}
	
	let(:database) {Relaxo.connect(database_path, test_key: "test_value")}
	
	let(:document_path) {'test/document.json'}
	let(:sample_json) {'[1, 2, 3]'}
	
	before(:each) {FileUtils.rm_rf(database_path)}
	
	it "should be initially empty" do
		expect(database).to be_empty
	end
	
	it "should not be empty with one document" do
		database.commit(message: "Create test document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path, oid)
		end
		
		expect(database).to_not be_empty
	end
	
	it "should have metadata" do
		expect(database[:test_key]).to be == "test_value"
	end
	
	it "should create a document" do
		database.commit(message: "Create test document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path, oid)
		end
		
		database.current do |dataset|
			expect(dataset[document_path].data).to be == sample_json
		end
	end
	
	it "should erase a document" do
		database.commit(message: "Create test document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path, oid)
		end
		
		database.commit(message: "Delete test document") do |dataset|
			dataset.delete(document_path)
		end
		
		database.current do |dataset|
			expect(dataset[document_path]).to be nil
		end
	end
	
	it "should create multiple documents" do
		database.commit(message: "Create first document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path, oid)
		end
		
		database.commit(message: "Create second document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path + '2', oid)
		end
		
		database.current do |dataset|
			expect(dataset[document_path].data).to be == sample_json
			expect(dataset[document_path + '2'].data).to be == sample_json
		end
	end
	
	it "can enumerate documents" do
		database.commit(message: "Create first document") do |dataset|
			oid = dataset.append(sample_json)
			
			10.times do |id|
				dataset.write(document_path + "-#{id}", oid)
			end
		end
		
		database.current do |dataset|
			expect(dataset.each('test').count).to be == 10
		end
	end
	
	it "can enumerate commit history of a document" do
		10.times do |id|
			database.commit(message: "revising the document #{id}") do |changeset|
				oid = changeset.append("revision \##{id} of this document")
				changeset.write('test/doot.txt', oid)
			end
		end
		
		database.commit(message: "unrelated commit") do |changeset|
			oid = changeset.append("unrelated document")
			changeset.write('test/unrelated.txt', oid)
		end
		
		expect(database.history('test/doot.txt').count).to be == 10
	end
end
