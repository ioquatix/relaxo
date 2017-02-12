# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require 'rugged'

module Relaxo
	class Directory
		def initialize(repository, tree, path)
			@repository = repository
			@tree = tree
			@path = path
			
			@entries = nil
			@changes = {}
		end
		
		def freeze
			@changes.freeze
			
			super
		end
		
		def entries
			@entries ||= load_entries!
		end
		
		def each(&block)
			return to_enum(:each) unless block_given?
			
			entries.each do |entry|
				entry[:object] ||= @repository.read(entry[:oid])
				
				yield entry[:name], entry[:object]
			end
		end
		
		def insert(entry)
			_, _, name = entry[:name].rpartition('/')
			
			@changes[name] = entry
			
			@entries = nil
		end
		
		def delete(entry)
			_, _, name = entry[:name].rpartition('/')
			
			@changes[name] = nil
			
			@entries = nil
		end
		
		private
		
		def fetch_tree(path = @path)
			entry = @tree.path(path)
			
			Rugged::Tree.new(@repository, entry[:oid])
		rescue Rugged::TreeError
			return nil
		end
		
		# Load the entries from the tree, applying any changes.
		def load_entries!
			entries = @changes
			@changes = {}
			
			if tree = fetch_tree
				tree.each_blob do |entry|
					unless entries.key? entry[:name]
						entries[entry[:name]] = entry
					end
				end
			end
			
			return entries.values.compact.sort_by{|entry| entry[:name]}
		end
	end
end
