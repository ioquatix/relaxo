# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2012-2024, by Samuel Williams.

require 'relaxo/database'

require 'etc'
require 'socket'

module Relaxo
	MASTER = 'master'.freeze
	
	def self.connect(path, branch: nil, sync: nil, create: true, **metadata)
		if !File.exist?(path) || create
			repository = Rugged::Repository.init_at(path, true)
			
			if sync || ENV['RELAXO_SYNC']
				repository.config['core.fsyncObjectFiles'] = true
			end
		end
		
		branch ||= MASTER
		
		database = Database.new(path, branch, metadata)
		
		if config = database.config
			unless config['user.name']
				login = Etc.getpwuid
				hostname = Socket.gethostname
				
				if login
					config['user.name'] = login.name
					config['user.email'] = "#{login.name}@#{hostname}"
				end
			end
		end
		
		return database
	end
end
