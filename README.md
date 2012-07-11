Relaxo
======

* Author: Samuel G. D. Williams (<http://www.oriontransfer.co.nz>)
* Copyright (C) 2012 Samuel G. D. Williams.
* Released under the MIT license.

Relaxo provides a set of tools and interfaces for interacting with CouchDB. It aims to be as simple and efficient as possible while still improving the usability of various CouchDB features.

Installation
------------

Install the ruby gem as follows:

	sudo gem install relaxo

To build and install the gem from source:

	cd build/
	sudo GEM=gem1.9 rake1.9 install_gem

Basic Usage
-----------

Connect to a local database and manipulate some documents.

	require 'relaxo'
	
	$database = Relaxo.connect("http://localhost:5984/test")
	
	doc1 = {:bob => 'dole'}
	$database.save(doc1)
	
	doc2 = $database.get(doc1['_id'])
	doc2[:foo] = 'bar'
	$database.save(doc2)

Bulk Changes/Sessions
---------------------

Sessions support a very similar interface to the main database class and can for many cases be used interchangeably, but with added efficiency.

	require 'relaxo'
	require 'relaxo/session'
	
	$database = Relaxo.connect("http://localhost:5984/test")
	
	$animals = ['Neko-san', 'Wan-chan', 'Nezu-chan', 'Chicken-san']
	
	$database.session do |session|
		$animals.each do |animal|
			session.save({:name => animal})
		end
	end
	# => [
	#	{:name=>"Neko-san", "_id"=>"...", "_rev"=>"..."},
	#	{:name=>"Wan-chan", "_id"=>"...", "_rev"=>"..."},
	#	{:name=>"Nezu-chan", "_id"=>"...", "_rev"=>"..."},
	#	{:name=>"Chicken-san", "_id"=>"...", "_rev"=>"..."}
	#]

All documents will allocated uuids appropriately and at the end of the session block they will be updated (saved or deleted)
using CouchDB `_bulk_save`.

To abort the session, either raise an exception or call `session.abort!` which is equivalent to `throw :abort`.

Loading Data
------------

Relaxo includes a command line script to import documents into a CouchDB database:

	relaxo http://localhost:5984/test design.yaml sample.yaml

Where `design.yaml` and `sample.yaml` contain lists of valid documents, e.g.:

	# design.yaml
	-   _id: "_design/services"
	    language: javascript
	    views:
	        service:
	            map: |
	                function(doc) {
	                    if (doc.type == 'service') {
	                        emit(doc._id, doc._rev);
	                    }
	                }

License
-------

Copyright (c) 2010, 2011 Samuel G. D. Williams. <http://www.oriontransfer.co.nz>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
