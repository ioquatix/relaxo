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
	
	it "should enumerate all documents including writes" do
		records = []
		
		database.commit(message: "Testing Enumeration") do |dataset|
			5.times do |i|
				object = dataset.append("extra-#{i}")
				dataset.write("#{prefix}/extra-#{i}", object)
			end
			
			expect(dataset.exist?("#{prefix}/extra-0")).to be_truthy
			
			records = dataset.each(prefix).to_a
		end
		
		expect(records.count).to be 25
	end
	
	it "should enumerate all documents excluding deletes" do
		records = database.commit(message: "Testing Enumeration") do |dataset|
			5.times do |i|
				dataset.delete("#{prefix}/#{i}")
			end
			
			expect(dataset.exist?("#{prefix}/0")).to be_falsey
			
			dataset.each(prefix).to_a
		end
		
		expect(records.count).to be 15
	end
	
	let(:author) do
		{name: 'Testing McTestface', email: 'testing@testing.com'}
	end
	
	it "can use specified author" do
		database.commit(message: "Testing Enumeration", author: author) do |dataset|
			object = dataset.append("Hello World!")
			dataset.write("hello.txt", object)
		end
		
		commit = database.head.target
		expect(commit.author).to include(author)
	end
end
