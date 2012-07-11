
require 'relaxo/client'

module Relaxo
	class Server
		UUID_COUNT = 10
		
		def initialize(url)
			@url = url
			@uuids = []
		end
		
		attr :url
		
		def next_uuid
			if @uuids.size == 0
				@uuids = Client.get("#{@url}/_uuids?count=#{UUID_COUNT}")["uuids"]
			end
			
			@uuids.pop
		end
		
		def info
			Client.get @url
		end
	end
end
