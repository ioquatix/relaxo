# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2025, by Samuel Williams.

require "relaxo/database"

require "etc"
require "socket"

module Relaxo
	DEFAULT_BRANCH = "main".freeze
	
	def self.connect(path, branch: nil, sync: nil, create: true, **metadata)
		if !File.exist?(path) || create
			repository = Rugged::Repository.init_at(path, true)
			
			if branch
				repository.head = "refs/heads/#{branch}"
			end
			
			if sync || ENV["RELAXO_SYNC"]
				repository.config["core.fsyncObjectFiles"] = true
			end
		else
			repository = Rugged::Repository.new(path)
		end
		
		# Automatically detect the current branch if `branch` is not provided:
		branch ||= self.default_branch(repository)
		
		database = Database.new(path, branch, metadata)
		
		if config = database.config
			unless config["user.name"]
				login = Etc.getpwuid
				hostname = Socket.gethostname
				
				if login
					config["user.name"] = login.name
					config["user.email"] = "#{login.name}@#{hostname}"
				end
			end
		end
		
		return database
	end
	
	private
	
	# Detect the default branch of the repository, taking into account unborn branches.
	def self.default_branch(repository)
		if head = repository.references["HEAD"]
			if target_id = head.target_id
				return target_id.sub(/^refs\/heads\//, "")
			end
		end
		
		return DEFAULT_BRANCH
	end
end
