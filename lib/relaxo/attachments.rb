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

require 'relaxo/database'

if RUBY_VERSION < "1.9"
	require 'relaxo/base64-1.8'
else
	require 'base64'
end

module Relaxo
	ATTACHMENTS = '_attachments'
	
	def self.encode_attachments!(document)
		return unless document[ATTACHMENTS]
		
		document[ATTACHMENTS].each do |name,contents|
			next if contents.include? 'stub'
			
			contents['data'] = Base64.strict_encode64(contents['data'])
		end
	end
	
	class Database
		def attach(document, name, data, options = {})
			parameters = {
				:rev => document[REV]
			}.merge(options[:parameters] || {})
			
			headers = {}
			
			if options[:headers]
				headers = options[:headers].dup
			else
				headers = {}
			end
			
			if options[:content_type]
				headers[:content_type] = options[:content_type]
			end
			
			Client.attach attachment_url(document[ID], name, parameters), data, headers
		end
		
		private
		
		def attachment_url(id, name, parameters = {})
			Client.encode_url("#{@root}/#{Client.escape_id(id)}/#{Client.escape(name)}", parameters)
		end
	end
end
