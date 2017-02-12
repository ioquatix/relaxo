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
	HEAD = 'HEAD'.freeze
	
	class Changeset < Dataset
		def initialize(repository, tree)
			super
			
			@changes = {}
			@directories = {}
		end
		
		def read(path)
			if update = @changes[path]
				if update[:action] != :remove
					lookup(update[:oid])
				end
			end
			
			super
		end
		
		def append(data, type = :blob)
			oid = @repository.write(data, type)
			
			return Rugged::Object.new(@repository, oid)
		end
		
		def write(path, object, mode = 0100644)
			root, _, name = path.rpartition('/')
			
			entry = @changes[path] = {
				action: :upsert,
				oid: object.oid,
				object: object,
				filemode: mode,
				path: path,
				root: root,
				name: name,
			}
			
			directory(root).insert(entry)
		end
		
		alias []= write
		
		def delete(path)
			root, _, name = path.rpartition('/')
			
			entry = @changes[path] = {
				action: :remove,
				path: path,
				root: root,
				name: name,
			}
			
			directory(path).delete(entry)
		end
		
		def parent
			@repository.empty? ? nil : @repository.head.target
		end
		
		def conflicts?
			false
		end
		
		def abort!
			throw :abort
		end
		
		def commit(**options)
			return true if @changes.empty?
			
			commit_parent = self.parent
			
			options[:tree] = @tree.update(@changes.values)
			options[:parents] ||= [commit_parent]
			options[:update_ref] ||= HEAD
			
			Rugged::Commit.create(@repository, options)
		end
	end
end
