# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2025, by Samuel Williams.
# Copyright, 2017, by Huba Nagy.

require "relaxo"
require "relaxo/test_records"

describe Relaxo::Database do
	include_context Relaxo::TemporaryDatabase
	
	let(:document_path) {"test/document.json"}
	let(:sample_json) {"[1, 2, 3]"}
	
	it "should be initially empty" do
		expect(database).to be(:empty?)
	end
	
	it "prepares user details in config" do
		expect(database.config.to_hash).to have_keys(
			"user.name", "user.email"
		)
	end
	
	it "can clear database" do
		database.clear!
		expect(database).to be(:empty?)
	end
	
	it "should not be empty with one document" do
		database.commit(message: "Create test document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path, oid)
		end
		
		expect(database).not.to be(:empty?)
	end
	
	it "should be able to clear the database" do
		database.commit(message: "Create test document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path, oid)
		end
		
		expect(database).not.to be(:empty?)
		
		database.clear!
		
		expect(database).to be(:empty?)
	end
	
	it "should have metadata" do
		expect(database.metadata).to be == {}
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
			expect(dataset[document_path]).to be_nil
		end
	end
	
	it "should create multiple documents" do
		database.commit(message: "Create first document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path, oid)
		end
		
		database.commit(message: "Create second document") do |dataset|
			oid = dataset.append(sample_json)
			dataset.write(document_path + "2", oid)
		end
		
		database.current do |dataset|
			expect(dataset[document_path].data).to be == sample_json
			expect(dataset[document_path + "2"].data).to be == sample_json
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
			expect(dataset.each("test").count).to be == 10
		end
	end
	
	it "can enumerate commit history of a document" do
		10.times do |id|
			database.commit(message: "revising the document #{id}") do |changeset|
				oid = changeset.append("revision \##{id} of this document")
				changeset.write("test/doot.txt", oid)
			end
		end
		
		database.commit(message: "unrelated commit") do |changeset|
			oid = changeset.append("unrelated document")
			changeset.write("test/unrelated.txt", oid)
		end
		
		expect(database.history("test/doot.txt").count).to be == 10
	end
end
