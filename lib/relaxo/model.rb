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

require 'relaxo/recordset'
require 'relaxo/properties'

module Relaxo
	def self.lowercase(string)
		string.gsub(/(.)([A-Z])/,'\1_\2').downcase!
	end
	
	class Model
		DEFAULT_VIEW_OPTIONS = {:include_docs => true}
		
		def self.inherited(child)
			# Include all available properties
			child.send(:include, Relaxo::Properties)
			
			child.class_variable_set(:@@properties, {})
			child.class_variable_set(:@@relationships, {})
		end
		
		def self.metaclass
			class << self; self; end
		end
		
		def initialize(database, document = {})
			# Raw key-value database
			@document = document
			@database = database
			@changed = {}
		end
		
		attr :database

		def id
			@document[ID]
		end

		def rev
			@document[REV]
		end

		def clear(key)
			@changed.delete(key)
			@document.delete(key)
		end

		def self.view(name, path, *args)
			options = Hash === args.last ? args.pop : DEFAULT_VIEW_OPTIONS
			klass = args.pop || options[:class]
			
			self.metaclass.send(:define_method, name) do |database, query = {}|
				records = database.view(path, query.merge(options))
				Recordset.new(database, records, klass)
			end
		end

		def self.relationship(name, path, *args)
			options = Hash === args.last ? args.pop : {}
			klass = args.pop || options[:class]
			
			self.class_variable_get(:@@relationships)[name] = options
			
			self.send(:define_method, name) do |query = {}|
				query = query.merge(options)
				
				unless query.include? :key
					query[:key] = self.id
				end
				
				Recordset.new(@database, @database.view(path, query), klass)
			end
		end

		def self.property(name, klass = nil)
			name = name.to_s
			
			self.class_variable_get(:@@properties)[name] = klass
			
			self.send(:define_method, name) do
				if @changed.include? name
					return @changed[name]
				elsif @document.include? name
					if klass
						@changed[name] = klass.convert_from_document(@database, @document[name])
					else
						@changed[name] = @document[name]
					end
				else
					nil
				end
			end
			
			self.send(:define_method, "#{name}=") do |value|
				@changed[name] = value
			end
		end

		def [] name
			name = name.to_s
			
			if self.class.class_variable_get(:@@properties).include? name
				self.send(name)
			else
				raise KeyError.new(name)
			end
		end
		
		def []= name, value
			name = name.to_s
			
			if self.class.class_variable_get(:@@properties).include? name
				self.send("#{name}=", value)
			else
				raise KeyError.new(name)
			end
		end

		def self.type
			if self.class_variable_defined? :@@type
				self.class_variable_get(:@@type)
			else
				Relaxo::lowercase(self.name.split('::').last)
			end
		end

		# Update any calculations:
		def before_save
		end

		def after_save
		end

		def save
			before_save

			return if @changed.size == 0 && self.id

			# Flatten changed properties:
			self.class.class_variable_get(:@@properties).each do |key, klass|
				if @changed.include? key
					if klass
						@document[key] = klass.convert_to_document(@changed.delete(key))
					else
						@document[key] = @changed.delete(key)
					end
				end
			end

			# Non-specific properties, serialised by JSON:
			@changed.each do |key, value|
				@document[key] = value
			end

			@changed = {}
			@database.save(@document)
			
			after_save
		end

		def before_delete
		end

		def after_delete
		end

		def delete
			before_delete
			
			@database.delete(@document)
			
			after_delete
		end

		def after_fetch
		end

		def self.fetch(database, id)
			instance = self.new(database, database.get(id).to_hash)
			
			instance.after_fetch
			
			return instance
		end

		# Set any default values:
		def after_create
		end

		def self.create(database, properties)
			instance = self.new(database, {'type' => self.type})

			properties.each do |key, value|
				instance[key] = value
			end

			instance.after_create

			return instance
		end
	end
end
