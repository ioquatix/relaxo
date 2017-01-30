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
	class Writer
		HEAD = 'HEAD'.freeze

		def initialize(repository)
			@repository = repository
			@index = Rugged::Index.new
			
			unless @repository.empty?
				tree = repository.head.target.tree
				@index.read_tree(tree)
			end
		end
		
		attr :repository
		attr :index
		
		private def fetch_object(path)
			if @index and entry = @index[path]
				if oid = entry[:oid]
					@repository.read(oid)
				end
			end
		end
		
		def read(path)
			# Perhaps add a cache in here if lookup is slow.
			if object = fetch_object(path)
				object.data
			end
		end
		
		alias [] read
		
		def write(path, data, type = :blob, mode = 0100644)
			oid = @repository.write(data, type)
			
			@index.add(path: path, oid: oid, mode: mode)
		end
		
		alias []= write
		
		def delete(path)
			@index.remove(path)
		end
		
		def each(pattern, &block)
			return to_enum(:each, pattern) unless block_given?
			
			if pattern
				# This huge hack can be removed once the git_index_find_prefix is implemented.
				found = false
				@index.each do |entry|
					path = entry[:path]
					
					if path.start_with? pattern
						found = true
					else
						break if found
					end
					
					yield(entry) if found
				end
			else
				@index.each(&block)
			end
		end
		
		def parents
			@repository.empty? ? [] : [@repository.head.target].compact
		end
		
		def conflicts?
			@index.conflicts?
		end
		
		def commit!(message)
			options = {
				tree: @index.write_tree(@repository),
				parents: self.parents,
				update_ref: HEAD,
				message: message
			}
			
			Rugged::Commit.create(@repository, options)
		end
	end
end
