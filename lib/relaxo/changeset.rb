# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2019, by Samuel Williams.

require_relative 'dataset'

module Relaxo
	class Changeset < Dataset
		def initialize(repository, tree)
			super
			
			@changes = {}
			@directories = {}
		end
		
		attr :ref
		attr :changes
		
		def changes?
			@changes.any?
		end
		
		def read(path)
			if update = @changes[path]
				if update[:action] != :remove
					@repository.read(update[:oid])
				end
			else
				super
			end
		end
		
		def append(data, type = :blob)
			oid = @repository.write(data, type)
			
			return @repository.read(oid)
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
			
			fetch_directory(root).insert(entry)
			
			return entry
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
			
			fetch_directory(root).delete(entry)
			
			return entry
		end
		
		def abort!
			throw :abort
		end
		
		def write_tree
			@tree.update(@changes.values)
		end
	end
end
