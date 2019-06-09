# Copyright, 2019, by Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

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
