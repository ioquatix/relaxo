
require 'relaxo/client'
require 'relaxo/server'

module Relaxo
	
	ID = '_id'
	REV = '_rev'
	ATTACHMENTS = '_attachments'
	
	def self.encode_attachments!(document)
		return unless document[ATTACHMENTS]
		
		document[ATTACHMENTS].each do |name,contents|
			next if contents['stub']
			
			contents['data'] = Base64.encode64(contents['data'])
		end
	end
	
	class Session
		def initialize(database)
			@database = database
			
			@documents = []
			@uuids = []
		end
		
		def get(*args)
			@database.get(*args)
		end
		
		def delete(document)
			@documents << {:_deleted => true}.merge(document)
		end
		
		def save(document)
			Relaxo::encode_attachments!(document)
			
			@documents << document
			
			# We assume the save operation will be successful:
			unless document.key? ID
				@uuids << (document[ID] = @database.server.next_uuid)
			end
		end
		
		def session(klass)
			yield self
			
			klass.new(self, @documents.last)
		end
		
		def view(*args)
			@database.view(*args)
		end
		
		def commit!
			#puts "Commiting session:"
			#puts YAML::dump(@documents)
			
			changed = []
			
			unless @documents.empty?
				results = @database.bulk_save @documents
				
				# Update the documents with revision information:
				@documents.each_with_index do |document, index|
					status = results[index]
					
					if status['ok']
						document[ID] = status['id']
						document[REV] = status['rev']
					end
				end
				
				changed = @documents
				@documents = []
			end
			
			return changed
		end
		
		#def rollback!
			# Restore all documents based on @uuids
		#end
	end
	
	class Database
		def initialize(server, name)
			@server = server
			@name = name
			
			@root = server.url + "/" + CGI.escape(name)
		end
		
		attr :server
		attr :name
		attr :root
		
		def get(id, parameters = {})
			Client.get document_url(id, parameters)
		end
		
		def put(document)
			Client.put document_url(document[ID] || @server.next_uuid), document
		end
		
		def delete(document)
			Client.delete document_url(document[ID]) + "?rev=#{document[REV]}"
		end
		
		def save(document)
			Relaxo::encode_attachments!(document)
			
			status = put(document)
			
			if status['ok']
				document[ID] = status['id']
				document[REV] = status['rev']
			end
			
			return status
		end
		
		def session(klass)
			session = Session.new(self)
			yield session
			changed = session.commit!
			
			klass.new(self, changed.last)
		end
		
		def bulk_save(documents)
			Client.post command_url("_bulk_docs"), {
				:docs => documents,
				:all_or_nothing => true
			}
		end
		
		# Query a CouchDB view as defined by a `_design` document. Accepts paramaters as described in http://wiki.apache.org/couchdb/HttpViewApi
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