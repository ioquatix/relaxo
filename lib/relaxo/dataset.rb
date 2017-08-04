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

require_relative 'directory'

module Relaxo
	class Dataset
		def initialize(repository, tree)
			@repository = repository
			@tree = tree
			
			@directories = {}
		end
		
		def read(path)
			if entry = @tree.path(path) and entry[:type] == :blob and oid = entry[:oid]
				@repository.read(oid)
			end
		rescue Rugged::TreeError
			return nil
		end
		
		alias [] read
		
		def file?
			read(path)
		end
		
		def exist?(path)
			read(path) or directory?(path)
		end
		
		def directory?(path)
			@directories.key?(path) or @tree.path(path)[:type] == :tree
		rescue Rugged::TreeError
			return false
		end
		
		def each(path = '', &block)
			return to_enum(:each, path) unless block_given?
			
			directory = fetch_directory(path)
			
			directory.each(&block)
		end
		
		protected
		
		def fetch_directory(path)
			@directories[path] ||= Directory.new(@repository, @tree, path)
		end
	end
end
