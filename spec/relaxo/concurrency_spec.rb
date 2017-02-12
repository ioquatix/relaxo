
require_relative 'test_records'

RSpec.describe Relaxo::Changeset do
	include_context "test records"
	
	it "should detect conflicts" do
		events = []
		
		alice = Fiber.new do
			database.commit(message: "Alice Data") do |changeset|
				events << :alice
				
				object = changeset.append("sample-data-1")
				changeset.write("conflict-path", object)
				
				Fiber.yield
			end
		end
		
		bob = Fiber.new do
			database.commit(message: "Bob Data") do |changeset|
				events << :bob
				
				object = changeset.append("sample-data-1")
				changeset.write("conflict-path", object)
				
				Fiber.yield
			end
		end
		
		alice.resume
		bob.resume
		alice.resume
		bob.resume
		
		expect(events).to be == [:alice, :bob, :bob]
	end
end
