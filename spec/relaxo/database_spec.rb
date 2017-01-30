
require 'relaxo'

RSpec.describe Relaxo::Database do
	let(:database) {Relaxo.connect(File.join(__dir__, 'test'))}
	
	let(:document_path) {'test/document.json'}
	let(:sample_json) {'[1, 2, 3]'}
	
	after(:each) {FileUtils.rm_rf(database.path)}
	
	it "should create a document" do
		database.commit!("Create test document") do |dataset|
			dataset.write(document_path, sample_json)
		end
		
		database.reader do |dataset|
			expect(dataset.read(document_path)).to be == sample_json
		end
	end
	
	it "should erase a document" do
		database.commit!("Create test document") do |dataset|
			dataset.write(document_path, sample_json)
		end
		
		database.commit!("Remove test document") do |dataset|
			dataset.delete(document_path)
		end
		
		database.reader do |dataset|
			expect(dataset.read(document_path)).to be_falsey
		end
	end
	
	it "should create multiple documents" do
		database.commit!("Create first document") do |dataset|
			dataset.write(document_path, sample_json)
		end
		
		database.commit!("Create second document") do |dataset|
			dataset.write(document_path + '2', sample_json)
		end
		
		database.reader do |dataset|
			expect(dataset.read(document_path)).to be == sample_json
			expect(dataset.read(document_path + '2')).to be == sample_json
		end
	end
	
	it "can enumerate documents" do
		
	end
end
