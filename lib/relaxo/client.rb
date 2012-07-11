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

require 'json'
require 'rest_client'
require 'cgi'

module Relaxo
	module Client
		DEFAULT_GET_HEADERS = {:accept => :json}
		DEFAULT_PUT_HEADERS = {:accept => :json, :content_type => :json}
		
		def self.execute(request)
			# Poor mans debugging:
			# $stderr.puts "#{request[:method]} #{request[:url]}..."
			
			response = RestClient::Request.execute(request)
			return JSON.parse(response)
		end
		
		def self.get(url)
			execute({
				:method => :get,
				:url => url,
				:headers => DEFAULT_GET_HEADERS
			})
		end
		
		def self.head(url)
			execute({
				:method => :head,
				:url => url,
				:headers => DEFAULT_GET_HEADERS
			})
		end
		
		def self.put(url, document)
			execute({
				:method => :put,
				:url => url,
				:headers => DEFAULT_PUT_HEADERS,
				:payload => JSON.generate(document)
			})
		end
		
		def self.post(url, document)
			execute({
				:method => :post,
				:url => url,
				:headers => DEFAULT_PUT_HEADERS,
				:payload => JSON.generate(document)
			})
		end
		
		def self.delete(url)
			execute({
				:method => :delete,
				:url => url,
				:headers => DEFAULT_PUT_HEADERS
			})
		end
		
		def self.escape(component)
			return CGI.escape(component)
		end
		
		def self.encode_parameters(parameters)
			query = []
			
			parameters.each do |key, value|
				key_string = key.to_s
				
				if Symbol === value || key_string.end_with?("docid")
					query << escape(key_string) + '=' + escape(value.to_s)
				else
					query << escape(key_string) + '=' + escape(value.to_json)
				end
			end
			
			return '?' + query.join('&')
		end
		
		def self.encode_url(url, parameters = {})
			if parameters.empty?
				url
			else
				url + encode_parameters(parameters)
			end
		end
		
		def self.escape_id(id)
			/^_design\/(.*)/ =~ id ? "_design/#{escape($1)}" : escape(id)
		end
	end
end