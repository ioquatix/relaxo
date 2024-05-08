# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2019, by Samuel Williams.

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
