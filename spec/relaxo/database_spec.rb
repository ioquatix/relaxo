
require 'relaxo'

RSpec.describe Relaxo::Database do
	let(:database) {Relaxo.connect(File.join(__dir__, 'test'))}
	
	let(:document_path) {'test/document.json'}
	let(:sample_json) {'[1, 2, 3]'}
	
	after(:each) {FileUtils.rm_rf(database.path)}
	
	it "should create a document" do
		database.transaction("Create test document") do |dataset|
			dataset.write(document_path, sample_json)
		end
		
		database.current do |dataset|
			expect(dataset[document_path]).to be == sample_json
		end
	end
	
	it "should erase a document" do
		database.transaction("Create test document") do |dataset|
			dataset.write(document_path, sample_json)
		end
		
		database.transaction("Remove test document") do |dataset|
			dataset.delete(document_path)
		end
		
		database.current do |dataset|
			expect(dataset[document_path]).to be nil
		end
	end
	
	it "should create multiple documents" do
		database.transaction("Create first document") do |dataset|
			dataset.write(document_path, sample_json)
		end
		
		database.transaction("Create second document") do |dataset|
			dataset.write(document_path + '2', sample_json)
		end
		
		database.current do |dataset|
			expect(dataset[document_path]).to be == sample_json
			expect(dataset[document_path + '2']).to be == sample_json
		end
	end
	
	it "can enumerate documents" do
		database.transaction("Create first document") do |dataset|
			10.times do |id|
				dataset.write(document_path + "-#{id}", sample_json)
			end
		end
		
		database.current do |dataset|
			expect(dataset.each('test').count).to be == 10
		end
	end
end
