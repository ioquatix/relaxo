# Copyright (c) 2012 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>
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
	class Dataset
		def initialize(repository, tree)
			@repository = repository
			@tree = tree
		end
		
		def lookup(oid)
			@repository.read(oid)
		end
		
		def read(path)
			if entry = @tree.path(path) and entry[:type] == :blob and oid = entry[:oid]
				lookup(oid)
			end
		rescue Rugged::TreeError
			return nil
		end
		
		alias [] read
		
		def exist?(path)
			read(path) != nil
		end
		
		def each(path = nil)
			return to_enum(:each, path) unless block_given?
			
			if tree = path ? fetch_tree(path) : @tree
				tree.each_blob do |entry|
					yield entry[:name], @repository.read(entry[:oid])
				end
			end
		end
		
		private
		
		def fetch_tree(path)
			entry = @tree.path(path)
			
			Rugged::Tree.new(@repository, entry[:oid])
		rescue Rugged::TreeError
			return nil
		end
	end
end
