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
	
	# We monkey-patch this in as Transaction is basically an optional feature for doing bulk_saves.
	class Database
		def transaction(klass = nil, metadata = {})
			transaction = Transaction.new(self, metadata)
			
			catch(:abort) do
				yield transaction
				
				changed = transaction.commit!
				
				if klass
					klass.new(self, changed.last)
				else
					changed
				end
			end
		end
	end
	
	class Transaction
		def initialize(database, metadata = {})
			@database = database
			@metadata = {}
			
			@documents = []
			@uuids = []
		end
		
		def [] key
			@metadata[key] || @database[key]
		end
		
		def get(*args)
			@database.get(*args)
		end
		
		def delete(document)
			@documents << {
				ID => document[ID],
				REV => document[REV],
				DELETED => true
			}
		end
		
		def save(document)
			@documents << document
			
			# We assume the save operation will be successful:
			unless document.key? ID
				@uuids << (document[ID] = @database.connection.next_uuid)
			end
		end
		
		def transaction(klass)
			yield self
			
			klass.new(self, @documents.last)
		end
		
		def view(*args)
			@database.view(*args)
		end
		
		def commit!
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
		
		def abort!
			throw :abort
		end
	end
end