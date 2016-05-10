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
require 'relaxo/connection'

module Relaxo
	ID = '_id'
	REV = '_rev'
	DELETED = '_deleted'
	
	class Database
		def initialize(connection, name, metadata = {})
			@connection = connection
			@name = name
			
			@metadata = metadata
			
			@root = connection.url + "/" + CGI.escape(name)
		end
		
		attr :connection
		attr :name
		attr :root
		
		attr :metadata
		
		def [] key
			@metadata[key]
		end
		
		# Create the database, will potentially throw an exception if it already exists.
		def create!
			Client.put @root
		end
		
		# Return true if the database already exists.
		def exist?
			Client.head @root
		end
		
		# Delete the database and all data.
		def delete!
			Client.delete @root
		end
		
		# Compact the database, removing old document revisions and optimizing space use.
		def compact!
			Client.post "#{@root}/_compact"
		end
		
		def id?(id, parameters = {})
			Client.head document_url(id, parameters)
		end
		
		def get(id, parameters = {})
			Client.get document_url(id, parameters)
		end
		
		def put(document)
			Client.put document_url(document[ID] || @connection.next_uuid), document
		end
		
		def delete(document)
			Client.delete document_url(document[ID]) + "?rev=#{document[REV]}"
		end
		
		def save(document)
			status = put(document)
			
			if status['ok']
				document[ID] = status['id']
				document[REV] = status['rev']
			end
			
			return status
		end
		
		def bulk_save(documents, options = {})
			options = {
				:docs => documents,
				:all_or_nothing => true
			}.merge(options)
			
			Client.post command_url("_bulk_docs"), options
		end
		
		# Accepts paramaters as described in http://wiki.apache.org/couchdb/HttpViewApi
		def view(name, parameters = {})
			Client.get view_url(name, parameters)
		end
		
		def info
			Client.get @root
		end
		
		def documents(parameters = {})
			view("_all_docs", parameters)
		end
		
		private
		
		# Convert a simplified view name into a complete view path. If the name already starts with a "_" no alterations will be made.
		def view_url(name, parameters = {})
			path = (name =~ /^([^_].+?)\/(.*)$/ ? "_design/#{$1}/_view/#{$2}" : name)
			
			Client.encode_url("#{@root}/#{path}", parameters)
		end
		
		def document_url(id, parameters = {})
			Client.encode_url("#{@root}/#{Client.escape_id(id)}", parameters)
		end
		
		def command_url(command, parameters = {})
			Client.encode_url("#{@root}/#{command}", parameters)
		end
	end
end
