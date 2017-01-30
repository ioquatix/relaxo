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

require_relative 'reader'
require_relative 'writer'

module Relaxo
	class Database
		def initialize(path, metadata = {})
			@path = path
			@metadata = metadata
			
			@repository = Rugged::Repository.new(path)
		end
		
		attr :path
		attr :metadata
		attr :repository
		
		def empty?
			@repository.empty?
		end
		
		def [] key
			@metadata[key]
		end
		
		def commit!(message)
			catch(:abort) do
				begin
					writer = Writer.new(@repository)
				
					yield writer
				end while writer.conflicts?
				
				writer.commit!(message)
			end
		end
		
		def empty?
			@repository.empty?
		end
		
		# Efficient point-in-time read-only access.
		def reader
			unless @repository.empty?
				Reader.new(@repository, @repository.head.target.tree)
			end
		end
	end
end
