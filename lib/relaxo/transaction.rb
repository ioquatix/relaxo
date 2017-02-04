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

require_relative 'dataset'

module Relaxo
	class Transaction < Dataset
		HEAD = 'HEAD'.freeze

		def initialize(repository, tree)
			super
			
			@index = Rugged::Index.new
			@index.read_tree(@tree)
		end
		
		def read(path)
			if entry = @index[path] and oid = entry[:oid]
				lookup(oid)
			end
		rescue Rugged::TreeError
			return nil
		end
		
		def append(data, type = :blob)
			oid = @repository.write(data, type)
			
			return Rugged::Object.new(@repository, oid)
		end
		
		def write(path, object, mode = 0100644)
			@index.add(path: path, oid: object.oid, mode: mode)
		end
		
		alias []= write
		
		def remove(path)
			@index.remove(path)
		end
		
		def each(path = nil)
			return to_enum(:each, path) unless block_given?
			
			if path
				# This huge hack can be removed once the git_index_find_prefix is implemented.
				found = false
				@index.each do |entry|
					path = entry[:path]
					
					if path.start_with? pattern
						found = true
					else
						break if found
					end
					
					if found and entry[:type] == :blob
						yield @repository.read(entry[:oid]).data
					end
				end
			else
				@index.each do |entry|
					if entry[:type] == :blob
						yield @repository.read(entry[:oid]).data
					end
				end
			end
		end
		
		def parents
			@repository.empty? ? [] : [@repository.head.target].compact
		end
		
		def conflicts?
			@index.conflicts?
		end
		
		def abort!
			throw :abort
		end
		
		def commit!(**options)
			options[:tree] = @index.write_tree(@repository)
			options[:parents] ||= self.parents
			options[:update_ref] ||= HEAD
			
			Rugged::Commit.create(@repository, options)
		end
	end
end
