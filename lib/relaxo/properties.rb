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

require 'date'

module Relaxo
	module Properties
		class Attribute
			@@attributes = {}
			
			def self.for_class(klass, &block)
				@@attributes[klass] = Proc.new(&block)
			end
			
			def self.[] klass
				self.new(klass)
			end
			
			def initialize(klass)
				@klass = klass
				
				self.instance_eval &@@attributes[klass]
			end
		end
		
		Attribute.for_class(Integer) do
			def convert_to_document(value)
				value.to_i
			end

			def convert_from_document(database, value)
				value.to_i
			end
		end
		
		Attribute.for_class(Float) do
			def convert_to_document(value)
				value.to_f
			end

			def convert_from_document(database, value)
				value.to_f
			end
		end
		
		Attribute.for_class(Date) do
			def convert_to_document(value)
				value.iso8601
			end

			def convert_from_document(database, string)
				Date.parse(string)
			end
		end

		Attribute.for_class(DateTime) do
			def convert_to_document(value)
				value.iso8601
			end

			def convert_from_document(database, string)
				DateTime.parse(string)
			end
		end

		Attribute.for_class(String) do
			def convert_to_document(value)
				value.to_s
			end

			def convert_from_document(database, string)
				string.to_s
			end
		end

		class BelongsTo
			def self.[] klass
				self.new(klass)
			end
			
			def initialize(klass)
				@klass = klass
			end

			def convert_to_document(value)
				unless value.id
					value.save
				end

				value.id
			end

			def convert_from_document(database, string)
				@klass.fetch(database, string)
			end
		end
		
		class Lookup
			def self.[] klass
				self.class.new(klass)
			end

			def initialize(klass)
				@klass = klass
			end

			def new(database, id)
				@klass.fetch(database, id)
			end
		end
	end
end
