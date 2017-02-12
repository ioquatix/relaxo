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
require 'logger'

require_relative 'dataset'
require_relative 'changeset'

module Relaxo
	class Database
		def initialize(path, metadata = {})
			@path = path
			@metadata = metadata
			
			@logger = metadata[:logger] || Logger.new($stderr, level: Logger::INFO)
			
			@repository = repository || Rugged::Repository.new(path)
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
		
		# During the execution of the block, changes don't get stored immediately, so reading from the dataset (from outside the block) will continue to return the values that were stored in the configuration when the transaction was started.
		def commit(**options)
			track_time(options[:message]) do
				catch(:abort) do
					begin
						changeset = Changeset.new(@repository, current_tree)
					
						yield changeset
					end until changeset.commit(**options)
				end
			end
		end
		
		# Efficient point-in-time read-only access.
		def current
			dataset = Dataset.new(@repository, current_tree)
			
			yield dataset if block_given?
			
			return dataset
		end
		
		private
		
		def track_time(message)
			start_time = Time.now
			
			yield
		ensure
			end_time = Time.now
			elapsed_time = end_time - start_time
			
			@logger.debug("time") {"#{message.inspect}: %0.3fs" % elapsed_time}
		end
		
		def current_tree
			if head = @repository.head
				head.target.tree
			else
				empty_tree
			end
		rescue Rugged::ReferenceError
			empty_tree
		end
		
		def empty_tree
			@empty_tree ||= Rugged::Tree.empty(@repository)
		end
	end
end
