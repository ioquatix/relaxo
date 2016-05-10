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

require 'relaxo/client'

module Relaxo
	class Connection
		DEFAULT_UUID_FETCH_COUNT = 10
		
		def initialize(url)
			@url = url
			@uuids = []
		end
		
		attr :url
		
		def fetch_uuids(count)
			@uuids += Client.get("#{@url}/_uuids?count=#{count}")["uuids"]
		end
		
		def next_uuid
			fetch_uuids(DEFAULT_UUID_FETCH_COUNT) if @uuids.size == 0
			
			@uuids.pop
		end
		
		def info
			Client.get @url
		end
		
		# Returns a list of names, one for each available database.
		def databases
			Client.get("#{@url}/_all_dbs")
		end
		
		def configuration
			Client.get("#{@url}/_config")
		end
	end
end
