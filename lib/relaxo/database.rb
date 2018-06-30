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
	HEAD = 'HEAD'.freeze
	
	class Database
		def initialize(path, branch, metadata = {})
			@path = path
			@metadata = metadata
			
			@logger = metadata[:logger] || Logger.new($stderr).tap{|logger| logger.level = Logger::INFO}
			
			@repository = Rugged::Repository.new(path)
			
			@branch = branch
		end
		
		attr :path
		attr :metadata
		attr :repository
		
		# Completely clear out the database.
		def clear!
			if head = @repository.branches[@branch]
				@repository.references.delete(head)
			end
		end
		
		def empty?
			@repository.empty?
		end
		
		def [] key
			@metadata[key]
		end
		
		# During the execution of the block, changes don't get stored immediately, so reading from the dataset (from outside the block) will continue to return the values that were stored in the configuration when the transaction was started.
		# @return the result of the block.
		def commit(**options)
			result = nil
			
			track_time(options[:message]) do
				catch(:abort) do
					begin
						parent, tree = latest_commit
						
						changeset = Changeset.new(@repository, tree)
						
						result = yield changeset
					end until apply(parent, changeset, **options)
				end
			end
			
			return result
		end
		
		# Efficient point-in-time read-only access.
		def current
			_, tree = latest_commit
			
			dataset = Dataset.new(@repository, tree)
			
			yield dataset if block_given?
			
			return dataset
		end
		
		# revision history of given object
		def history(path)
			head, _ = latest_commit
			
			walker = Rugged::Walker.new(@repository) # Sounds like 'Walker, Texas Ranger'...
			walker.sorting(Rugged::SORT_TOPO | Rugged::SORT_REVERSE)
			walker.push(head.oid)
			
			commits = []
			
			old_oid = nil
			
			walker.each do |commit|
				dataset = Dataset.new(@repository, commit.tree)
				oid = dataset.read(path).oid
				
				if oid != old_oid # modified
					yield commit if block_given?
					commits << commit
					old_oid = oid
				end
				
				break if oid.nil? && !old_oid.nil? # deleted or moved
			end
			
			return commits
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
		
		def apply(parent, changeset, **options)
			return true unless changeset.changes?
			
			options[:tree] = changeset.write_tree
			options[:parents] ||= [parent]
			options[:update_ref] ||= "refs/heads/#{@branch}"
			
			begin
				Rugged::Commit.create(@repository, options)
			rescue Rugged::ObjectError
				return false
			end
		end
		
		def latest_commit
			if head = @repository.branches[@branch]
				return head.target, head.target.tree
			else
				return nil, empty_tree
			end
		end
		
		def empty_tree
			@empty_tree ||= Rugged::Tree.empty(@repository)
		end
	end
end
