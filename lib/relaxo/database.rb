# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2025, by Samuel Williams.
# Copyright, 2017, by Huba Nagy.

require "rugged"

require_relative "logger"
require_relative "dataset"
require_relative "changeset"

module Relaxo
	HEAD = "HEAD".freeze
	
	class Database
		def initialize(path, branch, metadata = {})
			@path = path
			@metadata = metadata
			
			@repository = Rugged::Repository.new(path)
			# @repository.config['core.fsyncObjectFiles'] = fsync
			
			@branch = branch
		end
		
		def config
			@repository.config
		end
		
		attr :path
		attr :metadata
		attr :repository
		
		# @attribute branch [String] The branch that this database is currently working with.
		attr :branch
		
		# Completely clear out the database.
		def clear!
			if head = @repository.branches[@branch]
				@repository.references.delete(head)
			end
		end
		
		def empty?
			@repository.empty?
		end
		
		def head
			@repository.branches[@branch]
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
			
			Console.debug(self) {"#{message.inspect}: %0.3fs" % elapsed_time}
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
			if head = self.head
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
