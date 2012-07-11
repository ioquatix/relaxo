
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

module Relaxo
	class Recordset
		include Enumerable
		
		def initialize(database, view, klass = nil)
			@database = database
			@view = view
			
			@klass = klass
		end
		
		attr :klass
		attr :database
		
		def count
			@view["total_rows"]
		end
		
		def offset
			@view["offset"]
		end
		
		def rows
			@view["rows"]
		end
		
		def each(klass = nil, &block)
			klass ||= @klass
			
			if klass
				rows.each do |row|
					# If user specified :include_docs => true, row['doc'] contains the primary value:
					yield klass.new(@database, row['doc'] || row['value'])
				end
			else
				rows.each &block
			end
		end
	end
end
